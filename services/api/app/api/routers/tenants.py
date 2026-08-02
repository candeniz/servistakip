"""Tenant (müşteri şirket) yönetimi — yalnızca super_admin."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.user import Tenant, User
from app.schemas.common import Paginated
from app.schemas.entities import TenantCreate, TenantOut

router = APIRouter(prefix="/tenants", tags=["tenants"])

_super_admin = require_roles(Role.SUPER_ADMIN)


@router.get("", response_model=Paginated[TenantOut])
async def list_tenants(db: DbSession, _: User = Depends(_super_admin)) -> Paginated[TenantOut]:
    result = await db.execute(select(Tenant).order_by(Tenant.created_at.desc()))
    tenants = result.scalars().all()
    return Paginated[TenantOut](
        items=[TenantOut.model_validate(t) for t in tenants],
        total=len(tenants),
    )


@router.post("", response_model=TenantOut, status_code=201)
async def create_tenant(body: TenantCreate, db: DbSession, _: User = Depends(_super_admin)) -> TenantOut:
    exists = await db.execute(select(func.count()).where(Tenant.company_code == body.company_code))
    if exists.scalar_one() > 0:
        raise HTTPException(status_code=409, detail="Bu şirket kodu zaten kullanılıyor.")
    tenant = Tenant(
        name=body.name,
        company_code=body.company_code,
        primary_color=body.primary_color,
        user_limit=body.user_limit,
        vehicle_limit=body.vehicle_limit,
        status="active",
    )
    db.add(tenant)
    await db.flush()
    return TenantOut.model_validate(tenant)


@router.get("/{tenant_id}", response_model=TenantOut)
async def get_tenant(tenant_id: str, db: DbSession, _: User = Depends(_super_admin)) -> TenantOut:
    tenant = await db.get(Tenant, tenant_id)
    if tenant is None:
        raise HTTPException(status_code=404, detail="Şirket bulunamadı.")
    return TenantOut.model_validate(tenant)


@router.post("/{tenant_id}/activate", response_model=TenantOut)
async def activate_tenant(tenant_id: str, db: DbSession, _: User = Depends(_super_admin)) -> TenantOut:
    return await _set_status(db, tenant_id, "active")


@router.post("/{tenant_id}/suspend", response_model=TenantOut)
async def suspend_tenant(tenant_id: str, db: DbSession, _: User = Depends(_super_admin)) -> TenantOut:
    return await _set_status(db, tenant_id, "suspended")


async def _set_status(db: DbSession, tenant_id: str, new_status: str) -> TenantOut:
    tenant = await db.get(Tenant, tenant_id)
    if tenant is None:
        raise HTTPException(status_code=404, detail="Şirket bulunamadı.")
    tenant.status = new_status
    return TenantOut.model_validate(tenant)
