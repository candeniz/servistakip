"""Raporlama endpoint'leri (özet metrikler)."""
from fastapi import APIRouter, Depends
from sqlalchemy import func, select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.service import ServiceTrip, TripPassenger
from app.models.user import User

router = APIRouter(prefix="/reports", tags=["reports"])

_admin = require_roles(Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER, Role.SUPER_ADMIN)


async def _tenant_filter(stmt, current):
    if current.role != Role.SUPER_ADMIN.value:
        return stmt.where(ServiceTrip.tenant_id == current.tenant_id)
    return stmt


@router.get("/trips")
async def report_trips(db: DbSession, current: User = Depends(_admin)) -> dict:
    stmt = await _tenant_filter(select(ServiceTrip), current)
    trips = (await db.execute(stmt)).scalars().all()
    return {
        "total": len(trips),
        "completed": sum(1 for t in trips if t.status == "completed"),
        "active": sum(1 for t in trips if t.status in {"active", "delayed"}),
        "cancelled": sum(1 for t in trips if t.status == "cancelled"),
    }


@router.get("/punctuality")
async def report_punctuality(db: DbSession, current: User = Depends(_admin)) -> dict:
    stmt = await _tenant_filter(select(ServiceTrip), current)
    trips = (await db.execute(stmt)).scalars().all()
    delayed = [t for t in trips if t.delay_minutes > 0]
    avg_delay = sum(t.delay_minutes for t in delayed) / len(delayed) if delayed else 0
    return {
        "total_trips": len(trips),
        "delayed_trips": len(delayed),
        "average_delay_minutes": round(avg_delay, 1),
        "on_time_ratio": round(1 - (len(delayed) / len(trips)), 2) if trips else 1.0,
    }


@router.get("/passengers")
async def report_passengers(db: DbSession, current: User = Depends(_admin)) -> dict:
    stmt = select(func.count()).select_from(TripPassenger)
    if current.role != Role.SUPER_ADMIN.value:
        stmt = stmt.where(TripPassenger.tenant_id == current.tenant_id)
    total = (await db.execute(stmt)).scalar_one()
    boarded_stmt = stmt.where(TripPassenger.boarding_status == "boarded")
    boarded = (await db.execute(boarded_stmt)).scalar_one()
    return {"total_assignments": total, "boarded": boarded}


@router.get("/drivers")
async def report_drivers(db: DbSession, current: User = Depends(_admin)) -> dict:
    stmt = await _tenant_filter(select(ServiceTrip), current)
    trips = (await db.execute(stmt)).scalars().all()
    by_driver: dict[str, int] = {}
    for t in trips:
        if t.driver_id:
            by_driver[t.driver_id] = by_driver.get(t.driver_id, 0) + 1
    return {"trips_per_driver": by_driver}


@router.get("/routes")
async def report_routes(db: DbSession, current: User = Depends(_admin)) -> dict:
    stmt = await _tenant_filter(select(ServiceTrip), current)
    trips = (await db.execute(stmt)).scalars().all()
    return {"total_distance_meters": sum(t.total_distance for t in trips)}
