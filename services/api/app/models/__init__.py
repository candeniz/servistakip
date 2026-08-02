"""Tüm ORM modellerini tek yerden dışa aktarır (Alembic metadata için)."""
from app.models.fleet import Route, Stop, Vehicle
from app.models.misc import (
    AbsenceRequest,
    Announcement,
    AuditLog,
    Incident,
    Notification,
)
from app.models.service import (
    ServiceDefinition,
    ServiceTrip,
    TripPassenger,
    VehicleLocation,
)
from app.models.user import (
    DeviceToken,
    DriverProfile,
    EmployeeProfile,
    Tenant,
    User,
)

__all__ = [
    "Tenant",
    "User",
    "EmployeeProfile",
    "DriverProfile",
    "DeviceToken",
    "Vehicle",
    "Route",
    "Stop",
    "ServiceDefinition",
    "ServiceTrip",
    "TripPassenger",
    "VehicleLocation",
    "AbsenceRequest",
    "Notification",
    "Announcement",
    "Incident",
    "AuditLog",
]
