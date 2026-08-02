"""Servis tanımları (tekrar eden plan) yönetimi."""
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.service import ServiceDefinition, ServiceTrip
from app.models.user import User
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/service-definitions", tags=["services"])

_admin = require_roles(Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER)


class ServiceDefinitionCreate(BaseModel):
    name: str
    route_id: str
    vehicle_id: str | None = None
    driver_id: str | None = None
    direction: str = "morning"
    start_time: str = "06:30"
    active_days: str = "1,2,3,4,5"


class ServiceDefinitionOut(BaseModel):
    id: str
    name: str
    route_id: str
    vehicle_id: str | None
    driver_id: str | None
    direction: str
    start_time: str
    active_days: str
    status: str


@router.get("", response_model=list[ServiceDefinitionOut])
async def list_definitions(db: DbSession, current: User = Depends(_admin)) -> list[ServiceDefinitionOut]:
    result = await db.execute(select(ServiceDefinition).where(ServiceDefinition.tenant_id == current.tenant_id))
    return [ServiceDefinitionOut(**_row(d)) for d in result.scalars().all()]


@router.post("", response_model=ServiceDefinitionOut, status_code=201)
async def create_definition(
    body: ServiceDefinitionCreate, db: DbSession, current: User = Depends(_admin)
) -> ServiceDefinitionOut:
    definition = ServiceDefinition(tenant_id=current.tenant_id, **body.model_dump())
    db.add(definition)
    await db.flush()
    return ServiceDefinitionOut(**_row(definition))


@router.get("/{definition_id}", response_model=ServiceDefinitionOut)
async def get_definition(definition_id: str, db: DbSession, current: User = Depends(_admin)) -> ServiceDefinitionOut:
    definition = await db.get(ServiceDefinition, definition_id)
    if definition is None or definition.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Servis tanımı bulunamadı.")
    return ServiceDefinitionOut(**_row(definition))


@router.post("/{definition_id}/generate-trips", response_model=MessageResponse)
async def generate_trips(definition_id: str, db: DbSession, current: User = Depends(_admin)) -> MessageResponse:
    definition = await db.get(ServiceDefinition, definition_id)
    if definition is None or definition.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Servis tanımı bulunamadı.")
    # Bugün için tek bir yolculuk üret (haftalık plan üretimi prod'da genişletilir).
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    trip = ServiceTrip(
        tenant_id=definition.tenant_id,
        service_definition_id=definition.id,
        service_date=today,
        driver_id=definition.driver_id,
        vehicle_id=definition.vehicle_id,
        status="scheduled",
    )
    db.add(trip)
    return MessageResponse(detail="Yolculuk oluşturuldu.")


def _row(d: ServiceDefinition) -> dict:
    return {
        "id": d.id,
        "name": d.name,
        "route_id": d.route_id,
        "vehicle_id": d.vehicle_id,
        "driver_id": d.driver_id,
        "direction": d.direction,
        "start_time": d.start_time,
        "active_days": d.active_days,
        "status": d.status,
    }
