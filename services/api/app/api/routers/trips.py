"""Servis yolculukları — listeleme, yaşam döngüsü ve yolcu durumu."""
from fastapi import APIRouter, HTTPException
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession
from app.core.roles import ADMIN_ROLES, Role
from app.models.service import ServiceTrip, TripPassenger
from app.schemas.common import MessageResponse
from app.schemas.entities import BoardingUpdate, TripOut, TripPassengerOut
from app.services import trip_service

router = APIRouter(prefix="/trips", tags=["trips"])


def _can_access_trip(user, trip: ServiceTrip) -> bool:
    """Rol + tenant bazlı erişim kuralı."""
    if user.role == Role.SUPER_ADMIN.value:
        return True
    if user.tenant_id != trip.tenant_id:
        return False
    if user.role in {r.value for r in ADMIN_ROLES}:
        return True
    if user.role == Role.DRIVER.value:
        return trip.driver_id == user.id
    return False


async def _get_accessible_trip(db: DbSession, user, trip_id: str) -> ServiceTrip:
    trip = await db.get(ServiceTrip, trip_id)
    if trip is None or not _can_access_trip(user, trip):
        # Yetkisiz erişimde de 404 (varlık sızıntısını önler).
        raise HTTPException(status_code=404, detail="Servis bulunamadı.")
    return trip


@router.get("", response_model=list[TripOut])
async def list_trips(db: DbSession, current: CurrentUser) -> list[TripOut]:
    stmt = select(ServiceTrip)
    if current.role == Role.SUPER_ADMIN.value:
        pass  # tüm tenantlar
    elif current.role == Role.DRIVER.value:
        # Şoför yalnızca kendi servislerini görür.
        stmt = stmt.where(ServiceTrip.tenant_id == current.tenant_id, ServiceTrip.driver_id == current.id)
    else:
        stmt = stmt.where(ServiceTrip.tenant_id == current.tenant_id)
    result = await db.execute(stmt.order_by(ServiceTrip.service_date.desc()))
    return [TripOut.model_validate(t) for t in result.scalars().all()]


@router.post("/{trip_id}/prepare", response_model=TripOut)
async def prepare(trip_id: str, db: DbSession, current: CurrentUser) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.prepare_trip(db, trip_id))


@router.post("/{trip_id}/start", response_model=TripOut)
async def start(trip_id: str, db: DbSession, current: CurrentUser) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.start_trip(db, trip_id))


@router.post("/{trip_id}/arrive-stop", response_model=TripOut)
async def arrive_stop(trip_id: str, db: DbSession, current: CurrentUser, stop_id: str | None = None) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.arrive_stop(db, trip_id, stop_id))


@router.post("/{trip_id}/depart-stop", response_model=TripOut)
async def depart_stop(trip_id: str, db: DbSession, current: CurrentUser) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.depart_stop(db, trip_id))


@router.post("/{trip_id}/complete", response_model=TripOut)
async def complete(trip_id: str, db: DbSession, current: CurrentUser) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.complete_trip(db, trip_id))


@router.post("/{trip_id}/cancel", response_model=TripOut)
async def cancel(trip_id: str, db: DbSession, current: CurrentUser) -> TripOut:
    await _get_accessible_trip(db, current, trip_id)
    return TripOut.model_validate(await trip_service.cancel_trip(db, trip_id))


@router.get("/{trip_id}/passengers", response_model=list[TripPassengerOut])
async def trip_passengers(trip_id: str, db: DbSession, current: CurrentUser) -> list[TripPassengerOut]:
    await _get_accessible_trip(db, current, trip_id)
    result = await db.execute(select(TripPassenger).where(TripPassenger.service_trip_id == trip_id))
    return [TripPassengerOut.model_validate(p) for p in result.scalars().all()]


@router.patch("/{trip_id}/passengers/{passenger_id}", response_model=TripPassengerOut)
async def update_boarding(
    trip_id: str, passenger_id: str, body: BoardingUpdate, db: DbSession, current: CurrentUser
) -> TripPassengerOut:
    trip = await _get_accessible_trip(db, current, trip_id)
    # Yalnızca atanmış şoför veya yönetici biniş durumunu değiştirebilir.
    if current.role == Role.DRIVER.value and trip.driver_id != current.id:
        raise HTTPException(status_code=403, detail="Bu servise yetkiniz yok.")
    result = await db.execute(
        select(TripPassenger).where(
            TripPassenger.service_trip_id == trip_id, TripPassenger.passenger_id == passenger_id
        )
    )
    tp = result.scalar_one_or_none()
    if tp is None:
        raise HTTPException(status_code=404, detail="Yolcu bulunamadı.")
    tp.boarding_status = body.boarding_status
    if body.driver_note is not None:
        tp.driver_note = body.driver_note
    return TripPassengerOut.model_validate(tp)
