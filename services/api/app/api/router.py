"""Tüm REST router'larını tek yerde birleştirir."""
from fastapi import APIRouter

from app.api.routers import (
    auth,
    incidents,
    locations,
    notifications,
    passenger,
    reports,
    routes,
    services,
    tenants,
    trips,
    users,
    vehicles,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(tenants.router)
api_router.include_router(users.router)
api_router.include_router(vehicles.router)
api_router.include_router(routes.router)
api_router.include_router(services.router)
api_router.include_router(trips.router)
api_router.include_router(locations.router)
api_router.include_router(passenger.router)
api_router.include_router(incidents.router)
api_router.include_router(reports.router)
api_router.include_router(notifications.router)
