"""Olay (incident) yönetimi."""
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession
from app.core.roles import Role
from app.models.service import ServiceTrip
from app.models.misc import Incident

router = APIRouter(prefix="/incidents", tags=["incidents"])


class IncidentCreate(BaseModel):
    service_trip_id: str
    incident_type: str
    description: str
    latitude: float | None = None
    longitude: float | None = None


class IncidentOut(BaseModel):
    id: str
    service_trip_id: str
    incident_type: str
    description: str
    status: str
    created_at: datetime


@router.get("", response_model=list[IncidentOut])
async def list_incidents(db: DbSession, current: CurrentUser) -> list[IncidentOut]:
    stmt = select(Incident)
    if current.role != Role.SUPER_ADMIN.value:
        stmt = stmt.where(Incident.tenant_id == current.tenant_id)
    result = await db.execute(stmt.order_by(Incident.created_at.desc()))
    return [
        IncidentOut(
            id=i.id,
            service_trip_id=i.service_trip_id,
            incident_type=i.incident_type,
            description=i.description,
            status=i.status,
            created_at=i.created_at,
        )
        for i in result.scalars().all()
    ]


@router.post("", response_model=IncidentOut, status_code=201)
async def create_incident(body: IncidentCreate, db: DbSession, current: CurrentUser) -> IncidentOut:
    trip = await db.get(ServiceTrip, body.service_trip_id)
    if trip is None or trip.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Servis bulunamadı.")
    # Şoför yalnızca kendi servisinde olay bildirebilir.
    if current.role == Role.DRIVER.value and trip.driver_id != current.id:
        raise HTTPException(status_code=403, detail="Bu servise yetkiniz yok.")
    incident = Incident(
        tenant_id=trip.tenant_id,
        service_trip_id=trip.id,
        driver_id=current.id,
        vehicle_id=trip.vehicle_id,
        incident_type=body.incident_type,
        description=body.description,
        latitude=body.latitude,
        longitude=body.longitude,
        status="open",
        created_at=datetime.now(timezone.utc),
    )
    db.add(incident)
    await db.flush()
    return IncidentOut(
        id=incident.id,
        service_trip_id=incident.service_trip_id,
        incident_type=incident.incident_type,
        description=incident.description,
        status=incident.status,
        created_at=incident.created_at,
    )
