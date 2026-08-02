"""Demo veri yükleyici — Atlas Teknoloji senaryosu.

Çalıştırma:
    python -m app.seed

Idempotent: demo tenant zaten varsa hiçbir şey yapmaz.
Mobil uygulamadaki demo verisiyle aynı hesap ve değerleri kullanır.
"""
import asyncio
from datetime import datetime, timezone

from sqlalchemy import select

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.fleet import Route, Stop, Vehicle
from app.models.service import ServiceDefinition, ServiceTrip, TripPassenger
from app.models.user import Tenant, User

DEMO_PASSWORD = "Demo123!"
TENANT_CODE = "ATLAS01"

# (id, ad, lat, lng, offset dk) — mobil demoStops ile aynı
STOPS = [
    ("Esenyurt Merkez", 41.0341, 28.6800, 0),
    ("Haramidere", 41.0200, 28.6620, 6),
    ("Beylikdüzü Cumhuriyet", 41.0070, 28.6460, 12),
    ("Gürpınar Sahil", 40.9970, 28.6360, 18),
    ("Beylikdüzü Meydan", 41.0030, 28.6410, 24),  # yolcunun durağı (index 4)
    ("Yakuplu", 41.0120, 28.6570, 30),
    ("Beylikdüzü E-5", 41.0260, 28.6710, 36),
    ("Atlas Plaza (Varış)", 41.0450, 28.7020, 45),
]

PASSENGER_NAMES = [
    ("Zeynep", "Arslan", 4),  # yolcu@demo.com
    ("Emre", "Şahin", 0),
    ("Elif", "Yıldız", 0),
    ("Burak", "Koç", 1),
    ("Ayşe", "Aydın", 1),
    ("Can", "Öztürk", 2),
    ("Merve", "Doğan", 2),
    ("Deniz", "Kurt", 2),
    ("Kaan", "Çelik", 3),
    ("Selin", "Aslan", 3),
    ("Okan", "Polat", 4),
    ("Buse", "Erdoğan", 4),
    ("Tolga", "Şen", 5),
    ("Nur", "Bulut", 5),
    ("Hakan", "Acar", 6),
    ("Ceren", "Kılıç", 6),
    ("Mert", "Tuna", 7),
]


async def seed() -> None:
    # Tablolar yoksa oluştur (alembic çalışmadıysa güvenlik ağı).
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with SessionLocal() as db:
        existing = await db.execute(select(Tenant).where(Tenant.company_code == TENANT_CODE))
        if existing.scalar_one_or_none():
            print("Demo veri zaten mevcut, atlanıyor.")
            return

        # 1) Tenant
        tenant = Tenant(
            name="Atlas Teknoloji",
            company_code=TENANT_CODE,
            primary_color="#1E5EFF",
            status="active",
            package_id="pkg-pro",
            user_limit=250,
            vehicle_limit=20,
        )
        db.add(tenant)
        await db.flush()

        # 2) Kullanıcılar
        super_admin = User(
            tenant_id=None, first_name="Selin", last_name="Kaya",
            email="superadmin@demo.com", role="super_admin",
            password_hash=hash_password(DEMO_PASSWORD), status="active",
        )
        admin = User(
            tenant_id=tenant.id, first_name="Ahmet", last_name="Demir",
            email="yonetici@demo.com", role="company_admin",
            password_hash=hash_password(DEMO_PASSWORD), status="active",
        )
        driver = User(
            tenant_id=tenant.id, first_name="Mehmet", last_name="Yılmaz",
            email="sofor@demo.com", role="driver",
            password_hash=hash_password(DEMO_PASSWORD), status="active",
        )
        passenger = User(
            tenant_id=tenant.id, first_name="Zeynep", last_name="Arslan",
            email="yolcu@demo.com", role="passenger",
            password_hash=hash_password(DEMO_PASSWORD), status="active",
        )
        db.add_all([super_admin, admin, driver, passenger])
        await db.flush()

        # 3) Araç
        vehicle = Vehicle(
            tenant_id=tenant.id, plate_number="34 ST 2026", brand="Mercedes-Benz",
            model="Sprinter", year=2023, capacity=19, vehicle_type="minibus", status="active",
        )
        db.add(vehicle)
        await db.flush()

        # 4) Güzergâh + duraklar
        route = Route(
            tenant_id=tenant.id, name="Avrupa Yakası Sabah Güzergâhı", direction="morning",
            start_location="Esenyurt Merkez", end_location="Atlas Plaza",
            estimated_distance=22400, estimated_duration=45, status="active",
        )
        db.add(route)
        await db.flush()

        stop_rows: list[Stop] = []
        for index, (name, lat, lng, offset) in enumerate(STOPS):
            stop = Stop(
                tenant_id=tenant.id, route_id=route.id, name=name,
                latitude=lat, longitude=lng, order_index=index,
                planned_arrival_offset=offset, radius_meters=120, status="active",
            )
            stop_rows.append(stop)
            db.add(stop)
        await db.flush()

        # 5) Servis tanımı
        definition = ServiceDefinition(
            tenant_id=tenant.id, name="Avrupa Yakası Sabah Servisi", route_id=route.id,
            vehicle_id=vehicle.id, driver_id=driver.id, direction="morning",
            start_time="06:30", active_days="1,2,3,4,5", status="active",
        )
        db.add(definition)
        await db.flush()

        # 6) Bugünkü yolculuk (aktif)
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        trip = ServiceTrip(
            tenant_id=tenant.id, service_definition_id=definition.id, service_date=today,
            driver_id=driver.id, vehicle_id=vehicle.id,
            current_stop_id=stop_rows[0].id, next_stop_id=stop_rows[1].id,
            status="active", delay_minutes=3, total_distance=22400,
        )
        db.add(trip)
        await db.flush()

        # 7) Yolcular (demo yolcu = Zeynep, gerçek User kaydına bağlanır)
        for i, (first, last, stop_idx) in enumerate(PASSENGER_NAMES):
            if i == 0:
                pax_user = passenger  # yolcu@demo.com
            else:
                pax_user = User(
                    tenant_id=tenant.id, first_name=first, last_name=last,
                    email=f"pax{i}@demo.com", role="passenger",
                    password_hash=hash_password(DEMO_PASSWORD), status="active",
                )
                db.add(pax_user)
                await db.flush()
            db.add(
                TripPassenger(
                    tenant_id=tenant.id, service_trip_id=trip.id,
                    passenger_id=pax_user.id, stop_id=stop_rows[stop_idx].id,
                    boarding_status="expected",
                )
            )

        await db.commit()
        print("Demo veri yüklendi: Atlas Teknoloji, 4 demo hesap, 8 durak, 17 yolcu.")


if __name__ == "__main__":
    asyncio.run(seed())
