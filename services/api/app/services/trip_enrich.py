"""ServiceTrip / TripPassenger kayıtlarını mobil için zenginleştirir.

Ham ORM kayıtlarına servis adı, güzergâh adı, şoför adı, plaka, yolcu/durak
sayısı gibi bilgileri join'lerle ekler.
"""
from __future__ import annotations

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.fleet import Route, Stop, Vehicle
from app.models.service import ServiceDefinition, ServiceTrip, TripPassenger
from app.models.user import User
from app.schemas.entities import TripOut, TripPassengerOut


async def build_trip_out(db: AsyncSession, trip: ServiceTrip) -> TripOut:
    """Tek bir yolculuğu zenginleştirilmiş TripOut'a çevirir."""
    sd = (
        await db.get(ServiceDefinition, trip.service_definition_id)
        if trip.service_definition_id
        else None
    )
    route = await db.get(Route, sd.route_id) if sd and sd.route_id else None
    driver = await db.get(User, trip.driver_id) if trip.driver_id else None
    vehicle = await db.get(Vehicle, trip.vehicle_id) if trip.vehicle_id else None

    pax_count = (
        await db.execute(
            select(func.count()).select_from(TripPassenger).where(
                TripPassenger.service_trip_id == trip.id
            )
        )
    ).scalar_one()

    stop_count = 0
    if route is not None:
        stop_count = (
            await db.execute(
                select(func.count()).select_from(Stop).where(Stop.route_id == route.id)
            )
        ).scalar_one()

    base = TripOut.model_validate(trip)
    return base.model_copy(
        update={
            "service_name": sd.name if sd else "",
            "direction": sd.direction if sd else "morning",
            "route_id": route.id if route else "",
            "route_name": route.name if route else "",
            "driver_name": f"{driver.first_name} {driver.last_name}" if driver else "",
            "vehicle_plate": vehicle.plate_number if vehicle else "",
            "passenger_count": pax_count,
            "stop_count": stop_count,
        }
    )


async def build_trips_out(db: AsyncSession, trips: list[ServiceTrip]) -> list[TripOut]:
    return [await build_trip_out(db, t) for t in trips]


async def build_trip_passengers_out(db: AsyncSession, trip_id: str) -> list[TripPassengerOut]:
    """Yolcu kayıtlarını isim + durak adı ile zenginleştirir."""
    result = await db.execute(
        select(TripPassenger).where(TripPassenger.service_trip_id == trip_id)
    )
    out: list[TripPassengerOut] = []
    for tp in result.scalars().all():
        user = await db.get(User, tp.passenger_id)
        stop = await db.get(Stop, tp.stop_id)
        base = TripPassengerOut.model_validate(tp)
        out.append(
            base.model_copy(
                update={
                    "passenger_name": f"{user.first_name} {user.last_name}" if user else "",
                    "stop_name": stop.name if stop else "",
                }
            )
        )
    return out
