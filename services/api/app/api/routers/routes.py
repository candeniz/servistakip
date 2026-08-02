"""Güzergâh ve durak yönetimi."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import Role
from app.models.fleet import Route, Stop
from app.models.user import User
from app.schemas.common import MessageResponse, Paginated
from app.schemas.entities import RouteDetailOut, RouteOut, StopOut

router = APIRouter(prefix="/routes", tags=["routes"])

_admin = require_roles(Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER)


@router.get("", response_model=Paginated[RouteOut])
async def list_routes(db: DbSession, current: User = Depends(_admin)) -> Paginated[RouteOut]:
    result = await db.execute(select(Route).where(Route.tenant_id == current.tenant_id))
    items = result.scalars().all()
    return Paginated[RouteOut](items=[RouteOut.model_validate(r) for r in items], total=len(items))


@router.get("/{route_id}", response_model=RouteDetailOut)
async def get_route(route_id: str, db: DbSession, current: User = Depends(_admin)) -> RouteDetailOut:
    route = await db.get(Route, route_id)
    if route is None or route.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Güzergâh bulunamadı.")
    stops_result = await db.execute(
        select(Stop).where(Stop.route_id == route_id).order_by(Stop.order_index)
    )
    stops = [StopOut.model_validate(s) for s in stops_result.scalars().all()]
    detail = RouteDetailOut.model_validate(route)
    detail.stops = stops
    return detail


@router.get("/{route_id}/stops", response_model=list[StopOut])
async def list_stops(route_id: str, db: DbSession, current: User = Depends(_admin)) -> list[StopOut]:
    route = await db.get(Route, route_id)
    if route is None or route.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Güzergâh bulunamadı.")
    result = await db.execute(select(Stop).where(Stop.route_id == route_id).order_by(Stop.order_index))
    return [StopOut.model_validate(s) for s in result.scalars().all()]
