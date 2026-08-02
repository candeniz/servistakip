"""Araç yönetimi (tenant izolasyonlu)."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.fleet import Vehicle
from app.models.user import User
from app.schemas.common import MessageResponse, Paginated
from app.schemas.entities import VehicleCreate, VehicleOut

router = APIRouter(prefix="/vehicles", tags=["vehicles"])

_admin = require_roles(Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER)


@router.get("", response_model=Paginated[VehicleOut])
async def list_vehicles(db: DbSession, current: User = Depends(_admin)) -> Paginated[VehicleOut]:
    result = await db.execute(select(Vehicle).where(Vehicle.tenant_id == current.tenant_id))
    items = result.scalars().all()
    return Paginated[VehicleOut](items=[VehicleOut.model_validate(v) for v in items], total=len(items))


@router.post("", response_model=VehicleOut, status_code=201)
async def create_vehicle(body: VehicleCreate, db: DbSession, current: User = Depends(_admin)) -> VehicleOut:
    vehicle = Vehicle(tenant_id=current.tenant_id, **body.model_dump())
    db.add(vehicle)
    await db.flush()
    return VehicleOut.model_validate(vehicle)


async def _scoped(db: DbSession, current, vehicle_id: str) -> Vehicle:
    vehicle = await db.get(Vehicle, vehicle_id)
    if vehicle is None or vehicle.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Araç bulunamadı.")
    return vehicle


@router.get("/{vehicle_id}", response_model=VehicleOut)
async def get_vehicle(vehicle_id: str, db: DbSession, current: User = Depends(_admin)) -> VehicleOut:
    return VehicleOut.model_validate(await _scoped(db, current, vehicle_id))


@router.patch("/{vehicle_id}", response_model=VehicleOut)
async def update_vehicle(vehicle_id: str, body: VehicleCreate, db: DbSession, current: User = Depends(_admin)) -> VehicleOut:
    vehicle = await _scoped(db, current, vehicle_id)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(vehicle, field, value)
    return VehicleOut.model_validate(vehicle)


@router.delete("/{vehicle_id}", response_model=MessageResponse)
async def delete_vehicle(vehicle_id: str, db: DbSession, current: User = Depends(_admin)) -> MessageResponse:
    vehicle = await _scoped(db, current, vehicle_id)
    vehicle.status = "passive"
    return MessageResponse(detail="Araç pasife alındı.")
