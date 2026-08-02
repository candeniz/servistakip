"""Konum gönderimi ve sorgusu — yalnızca aktif serviste ve atanmış şoför."""
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from sqlalchemy import select

from app.core.constants import MAX_ACCEPTABLE_ACCURACY_M, WS_EVENTS, ws_trip_location
from app.core.deps import CurrentUser, DbSession
from app.core.redis import publish
from app.core.roles import Role
from app.models.service import ServiceTrip, VehicleLocation
from app.schemas.entities import LocationCreate, LocationOut

router = APIRouter(prefix="/trips", tags=["locations"])


@router.post("/{trip_id}/locations", response_model=LocationOut, status_code=201)
async def post_location(trip_id: str, body: LocationCreate, db: DbSession, current: CurrentUser) -> LocationOut:
    trip = await db.get(ServiceTrip, trip_id)
    if trip is None:
        raise HTTPException(status_code=404, detail="Servis bulunamadı.")

    # Yalnızca atanmış şoför konum gönderebilir.
    if current.role != Role.DRIVER.value or trip.driver_id != current.id:
        raise HTTPException(status_code=403, detail="Konum gönderme yetkiniz yok.")

    # Konum yalnızca aktif/gecikmeli serviste kabul edilir.
    if trip.status not in {"active", "delayed"}:
        raise HTTPException(status_code=409, detail="Servis aktif değil.")

    # GPS doğruluğu çok kötüyse reddet.
    if body.accuracy and body.accuracy > MAX_ACCEPTABLE_ACCURACY_M:
        raise HTTPException(status_code=422, detail="Konum doğruluğu yetersiz.")

    loc = VehicleLocation(
        tenant_id=trip.tenant_id,
        service_trip_id=trip.id,
        vehicle_id=trip.vehicle_id,
        driver_id=current.id,
        latitude=body.latitude,
        longitude=body.longitude,
        speed=body.speed,
        heading=body.heading,
        accuracy=body.accuracy,
        recorded_at=datetime.now(timezone.utc),
    )
    db.add(loc)
    await db.flush()

    # İlgili trip kanalına yayınla (yalnızca bu servisin aboneleri alır).
    await publish(
        ws_trip_location(trip.id),
        WS_EVENTS["LOCATION_UPDATE"],
        {
            "service_trip_id": trip.id,
            "latitude": body.latitude,
            "longitude": body.longitude,
            "speed": body.speed,
            "heading": body.heading,
            "recorded_at": loc.recorded_at.isoformat(),
        },
    )
    return LocationOut.model_validate(loc)


@router.get("/{trip_id}/latest-location", response_model=LocationOut | None)
async def latest_location(trip_id: str, db: DbSession, current: CurrentUser) -> LocationOut | None:
    trip = await db.get(ServiceTrip, trip_id)
    if trip is None or (current.role != Role.SUPER_ADMIN.value and trip.tenant_id != current.tenant_id):
        raise HTTPException(status_code=404, detail="Servis bulunamadı.")
    result = await db.execute(
        select(VehicleLocation)
        .where(VehicleLocation.service_trip_id == trip_id)
        .order_by(VehicleLocation.recorded_at.desc())
        .limit(1)
    )
    loc = result.scalar_one_or_none()
    return LocationOut.model_validate(loc) if loc else None


@router.get("/{trip_id}/location-history", response_model=list[LocationOut])
async def location_history(trip_id: str, db: DbSession, current: CurrentUser) -> list[LocationOut]:
    trip = await db.get(ServiceTrip, trip_id)
    if trip is None or (current.role != Role.SUPER_ADMIN.value and trip.tenant_id != current.tenant_id):
        raise HTTPException(status_code=404, detail="Servis bulunamadı.")
    result = await db.execute(
        select(VehicleLocation)
        .where(VehicleLocation.service_trip_id == trip_id)
        .order_by(VehicleLocation.recorded_at.asc())
        .limit(500)
    )
    return [LocationOut.model_validate(l) for l in result.scalars().all()]
