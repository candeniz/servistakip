"""Pytest fixtures — SQLite (aiosqlite) üzerinde izole test ortamı."""
import os

# app.* modülleri içe aktarılmadan ÖNCE test veritabanını sqlite'a çevir;
# böylece modül düzeyindeki engine postgres sürücüsünü (asyncpg) yüklemeye çalışmaz.
os.environ.setdefault("DATABASE_URL", "sqlite+aiosqlite:///./_test_app.db")

from collections.abc import AsyncGenerator
from datetime import datetime, timezone

import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.core.security import hash_password
from app.main import app
from app.models.fleet import Route, Stop, Vehicle
from app.models.service import ServiceDefinition, ServiceTrip, TripPassenger
from app.models.user import Tenant, User

TEST_DB_URL = "sqlite+aiosqlite:///:memory:"

# StaticPool: tüm oturumlar aynı in-memory bağlantıyı paylaşır; böylece
# oluşturulan tablolar tüm testlerde görünür.
engine = create_async_engine(
    TEST_DB_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestSession = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


@pytest_asyncio.fixture(autouse=True)
async def _prepare_db() -> AsyncGenerator[None, None]:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await _seed()
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


async def _override_get_db() -> AsyncGenerator[AsyncSession, None]:
    async with TestSession() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise


app.dependency_overrides[get_db] = _override_get_db


# Test veri kimlikleri (testlerde referans için sabit).
TENANT_ID = "t-atlas"
DRIVER_ID = "u-driver"
PASSENGER_ID = "u-passenger"
OTHER_PASSENGER_ID = "u-passenger2"
TRIP_ID = "trip-1"
STOP_IDS = [f"stop-{i}" for i in range(4)]
PASSWORD = "Demo123!"


async def _seed() -> None:
    async with TestSession() as db:
        tenant = Tenant(id=TENANT_ID, name="Atlas", company_code="ATLAS01", status="active")
        db.add(tenant)
        db.add_all(
            [
                User(id="u-superadmin", tenant_id=None, first_name="S", last_name="A",
                     email="superadmin@demo.com", role="super_admin",
                     password_hash=hash_password(PASSWORD), status="active"),
                User(id="u-admin", tenant_id=TENANT_ID, first_name="A", last_name="D",
                     email="yonetici@demo.com", role="company_admin",
                     password_hash=hash_password(PASSWORD), status="active"),
                User(id=DRIVER_ID, tenant_id=TENANT_ID, first_name="M", last_name="Y",
                     email="sofor@demo.com", role="driver",
                     password_hash=hash_password(PASSWORD), status="active"),
                User(id=PASSENGER_ID, tenant_id=TENANT_ID, first_name="Z", last_name="A",
                     email="yolcu@demo.com", role="passenger",
                     password_hash=hash_password(PASSWORD), status="active"),
                User(id=OTHER_PASSENGER_ID, tenant_id=TENANT_ID, first_name="B", last_name="C",
                     email="yolcu2@demo.com", role="passenger",
                     password_hash=hash_password(PASSWORD), status="active"),
            ]
        )
        vehicle = Vehicle(id="v-1", tenant_id=TENANT_ID, plate_number="34 ST 2026",
                          brand="MB", model="Sprinter", year=2023, capacity=19, status="active")
        route = Route(id="r-1", tenant_id=TENANT_ID, name="Sabah", direction="morning",
                      start_location="A", end_location="B", estimated_distance=1000,
                      estimated_duration=20, status="active")
        db.add_all([vehicle, route])
        coords = [(41.0, 28.6), (41.01, 28.62), (41.02, 28.64), (41.03, 28.66)]
        for i, (lat, lng) in enumerate(coords):
            db.add(Stop(id=STOP_IDS[i], tenant_id=TENANT_ID, route_id="r-1", name=f"Durak {i}",
                        latitude=lat, longitude=lng, order_index=i,
                        planned_arrival_offset=i * 6, radius_meters=120, status="active"))
        definition = ServiceDefinition(id="sd-1", tenant_id=TENANT_ID, name="Sabah Servisi",
                                       route_id="r-1", vehicle_id="v-1", driver_id=DRIVER_ID,
                                       direction="morning", start_time="06:30", status="active")
        db.add(definition)
        trip = ServiceTrip(id=TRIP_ID, tenant_id=TENANT_ID, service_definition_id="sd-1",
                           service_date=datetime.now(timezone.utc).strftime("%Y-%m-%d"),
                           driver_id=DRIVER_ID, vehicle_id="v-1",
                           current_stop_id=STOP_IDS[0], next_stop_id=STOP_IDS[1],
                           status="active", delay_minutes=0, total_distance=1000)
        db.add(trip)
        db.add(TripPassenger(id="tp-1", tenant_id=TENANT_ID, service_trip_id=TRIP_ID,
                             passenger_id=PASSENGER_ID, stop_id=STOP_IDS[2],
                             boarding_status="expected"))
        await db.commit()


@pytest_asyncio.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


async def login(client: AsyncClient, email: str) -> str:
    resp = await client.post("/auth/login", json={"email": email, "password": PASSWORD})
    assert resp.status_code == 200, resp.text
    return resp.json()["tokens"]["access_token"]


def auth_header(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}
