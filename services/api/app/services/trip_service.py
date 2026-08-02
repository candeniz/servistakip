"""Servis yolculuğu yaşam döngüsü işlemleri."""
from datetime import datetime, timezone

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.constants import WS_EVENTS, ws_trip_location, ws_tenant_operations
from app.core.redis import publish
from app.models.fleet import Stop
from app.models.service import ServiceTrip


async def _get_trip(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await db.get(ServiceTrip, trip_id)
    if trip is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Servis bulunamadı.")
    return trip


async def _ordered_stops(db: AsyncSession, trip: ServiceTrip) -> list[Stop]:
    # Tenant içindeki durakları order_index'e göre getir.
    result = await db.execute(
        select(Stop).where(Stop.tenant_id == trip.tenant_id).order_by(Stop.order_index)
    )
    return list(result.scalars().all())


async def prepare_trip(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    trip.status = "preparing"
    return trip


async def start_trip(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    if trip.status in {"completed", "cancelled"}:
        raise HTTPException(status_code=400, detail="Servis başlatılamaz.")
    trip.status = "active"
    trip.actual_start_at = datetime.now(timezone.utc)
    await publish(ws_tenant_operations(trip.tenant_id), WS_EVENTS["TRIP_STATUS"], {"trip_id": trip.id, "status": "active"})
    return trip


async def arrive_stop(db: AsyncSession, trip_id: str, stop_id: str | None = None) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    if stop_id:
        trip.current_stop_id = stop_id
    await publish(ws_trip_location(trip.id), WS_EVENTS["STOP_ARRIVED"], {"stop_id": trip.current_stop_id})
    return trip


async def depart_stop(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    stops = await _ordered_stops(db, trip)
    # Sıradaki durağı ilerlet.
    if trip.current_stop_id:
        ids = [s.id for s in stops]
        if trip.current_stop_id in ids:
            idx = ids.index(trip.current_stop_id)
            trip.next_stop_id = ids[idx + 1] if idx + 1 < len(ids) else None
    await publish(ws_trip_location(trip.id), WS_EVENTS["STOP_DEPARTED"], {"next_stop_id": trip.next_stop_id})
    return trip


async def complete_trip(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    trip.status = "completed"
    trip.actual_end_at = datetime.now(timezone.utc)
    await publish(ws_tenant_operations(trip.tenant_id), WS_EVENTS["TRIP_STATUS"], {"trip_id": trip.id, "status": "completed"})
    return trip


async def cancel_trip(db: AsyncSession, trip_id: str) -> ServiceTrip:
    trip = await _get_trip(db, trip_id)
    trip.status = "cancelled"
    await publish(ws_tenant_operations(trip.tenant_id), WS_EVENTS["TRIP_STATUS"], {"trip_id": trip.id, "status": "cancelled"})
    return trip
