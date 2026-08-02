"""Yolcu endpoint'leri — yolcu yalnızca kendi servislerini görür."""
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.fleet import Stop
from app.models.misc import AbsenceRequest, Notification
from app.models.service import ServiceTrip, TripPassenger, VehicleLocation
from app.schemas.common import MessageResponse
from app.schemas.entities import EtaOut, TripOut
from app.services.eta_service import EtaInput, get_eta_provider
from app.services.trip_enrich import build_trip_out, build_trips_out
from pydantic import BaseModel

router = APIRouter(prefix="/passenger", tags=["passenger"])

_passenger = require_roles(Role.PASSENGER)


async def _passenger_trip_ids(db: DbSession, passenger_id: str) -> list[str]:
    result = await db.execute(
        select(TripPassenger.service_trip_id).where(TripPassenger.passenger_id == passenger_id)
    )
    return [row[0] for row in result.all()]


@router.get("/today", response_model=list[TripOut])
async def today(db: DbSession, current: CurrentUser) -> list[TripOut]:
    ids = await _passenger_trip_ids(db, current.id)
    if not ids:
        return []
    today_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    result = await db.execute(
        select(ServiceTrip).where(ServiceTrip.id.in_(ids), ServiceTrip.service_date == today_str)
    )
    return await build_trips_out(db, list(result.scalars().all()))


@router.get("/current-trip", response_model=TripOut)
async def current_trip(db: DbSession, current: CurrentUser) -> TripOut:
    ids = await _passenger_trip_ids(db, current.id)
    if not ids:
        raise HTTPException(status_code=404, detail="Size atanmış aktif servis bulunmuyor.")
    result = await db.execute(
        select(ServiceTrip)
        .where(ServiceTrip.id.in_(ids), ServiceTrip.status.in_(["active", "delayed", "preparing"]))
        .order_by(ServiceTrip.service_date.desc())
        .limit(1)
    )
    trip = result.scalar_one_or_none()
    if trip is None:
        raise HTTPException(status_code=404, detail="Aktif servis bulunamadı.")
    return await build_trip_out(db, trip)


@router.get("/current-trip/eta", response_model=EtaOut)
async def current_trip_eta(db: DbSession, current: CurrentUser) -> EtaOut:
    ids = await _passenger_trip_ids(db, current.id)
    if not ids:
        raise HTTPException(status_code=404, detail="Aktif servis bulunamadı.")
    trip_result = await db.execute(
        select(ServiceTrip).where(ServiceTrip.id.in_(ids), ServiceTrip.status.in_(["active", "delayed"])).limit(1)
    )
    trip = trip_result.scalar_one_or_none()
    if trip is None:
        raise HTTPException(status_code=404, detail="Aktif servis bulunamadı.")

    # Yolcunun durağı
    tp_result = await db.execute(
        select(TripPassenger).where(
            TripPassenger.service_trip_id == trip.id, TripPassenger.passenger_id == current.id
        )
    )
    tp = tp_result.scalar_one()
    stops_result = await db.execute(
        select(Stop).where(Stop.tenant_id == trip.tenant_id).order_by(Stop.order_index)
    )
    stops = list(stops_result.scalars().all())
    stop_ids = [s.id for s in stops]
    target_index = stop_ids.index(tp.stop_id) if tp.stop_id in stop_ids else len(stops) - 1
    next_index = stop_ids.index(trip.next_stop_id) if trip.next_stop_id in stop_ids else 0

    loc_result = await db.execute(
        select(VehicleLocation)
        .where(VehicleLocation.service_trip_id == trip.id)
        .order_by(VehicleLocation.recorded_at.desc())
        .limit(1)
    )
    loc = loc_result.scalar_one_or_none()
    if loc is None:
        raise HTTPException(status_code=409, detail="Şoför henüz konum paylaşmıyor.")

    provider = get_eta_provider()
    result = provider.calculate(
        EtaInput(
            vehicle_lat=loc.latitude,
            vehicle_lng=loc.longitude,
            stops=stops,
            next_stop_index=next_index,
            target_stop_index=target_index,
            planned_arrival_at=trip.planned_end_at,
        )
    )
    return EtaOut(**result.__dict__)


class AbsenceRequestBody(BaseModel):
    start_date: str
    end_date: str
    morning_absent: bool = False
    evening_absent: bool = False
    reason: str | None = None


@router.post("/absence", response_model=MessageResponse)
async def create_absence(body: AbsenceRequestBody, db: DbSession, current: CurrentUser) -> MessageResponse:
    absence = AbsenceRequest(
        tenant_id=current.tenant_id or "",
        passenger_id=current.id,
        start_date=body.start_date,
        end_date=body.end_date,
        morning_absent=body.morning_absent,
        evening_absent=body.evening_absent,
        reason=body.reason,
        status="approved",
    )
    db.add(absence)
    return MessageResponse(detail="İzin talebiniz kaydedildi.")


@router.get("/trip-history", response_model=list[TripOut])
async def trip_history(db: DbSession, current: CurrentUser) -> list[TripOut]:
    ids = await _passenger_trip_ids(db, current.id)
    if not ids:
        return []
    result = await db.execute(
        select(ServiceTrip)
        .where(ServiceTrip.id.in_(ids), ServiceTrip.status == "completed")
        .order_by(ServiceTrip.service_date.desc())
    )
    return await build_trips_out(db, list(result.scalars().all()))


@router.get("/notifications")
async def notifications(db: DbSession, current: CurrentUser) -> dict:
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current.id)
        .order_by(Notification.created_at.desc())
        .limit(100)
    )
    items = result.scalars().all()
    return {
        "items": [
            {
                "id": n.id,
                "tenant_id": n.tenant_id,
                "user_id": n.user_id,
                "title": n.title,
                "message": n.message,
                "type": n.type,
                "data": None,
                "read_at": n.read_at.isoformat() if n.read_at else None,
                "created_at": n.created_at.isoformat(),
            }
            for n in items
        ],
        "total": len(items),
    }
