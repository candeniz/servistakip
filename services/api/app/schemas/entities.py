"""Varlık şemaları (tenant, vehicle, route, trip vb.)."""
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ── Tenant ──────────────────────────────────────────────
class TenantCreate(BaseModel):
    name: str = Field(min_length=2)
    company_code: str = Field(min_length=2)
    primary_color: str | None = None
    user_limit: int = 50
    vehicle_limit: int = 10


class TenantOut(ORMModel):
    id: str
    name: str
    company_code: str
    logo_url: str | None
    primary_color: str | None
    status: str
    package_id: str | None
    user_limit: int
    vehicle_limit: int
    created_at: datetime
    updated_at: datetime


# ── User ────────────────────────────────────────────────
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone: str | None = None
    role: str
    password: str = Field(min_length=8)


class UserUpdate(BaseModel):
    first_name: str | None = None
    last_name: str | None = None
    phone: str | None = None
    status: str | None = None


class UserOut(ORMModel):
    id: str
    tenant_id: str | None
    first_name: str
    last_name: str
    email: str
    phone: str | None
    role: str
    status: str
    profile_photo: str | None


# ── Vehicle ─────────────────────────────────────────────
class VehicleCreate(BaseModel):
    plate_number: str
    brand: str
    model: str
    year: int = 2020
    capacity: int = 16
    vehicle_type: str = "minibus"


class VehicleOut(ORMModel):
    id: str
    tenant_id: str
    plate_number: str
    brand: str
    model: str
    year: int
    capacity: int
    vehicle_type: str
    inspection_expiry_date: str | None
    insurance_expiry_date: str | None
    status: str


# ── Route / Stop ────────────────────────────────────────
class StopOut(ORMModel):
    id: str
    tenant_id: str
    route_id: str
    name: str
    latitude: float
    longitude: float
    order_index: int
    planned_arrival_offset: int
    radius_meters: int
    status: str


class RouteOut(ORMModel):
    id: str
    tenant_id: str
    name: str
    direction: str
    start_location: str
    end_location: str
    encoded_polyline: str | None
    estimated_distance: float
    estimated_duration: int
    status: str


class RouteDetailOut(RouteOut):
    stops: list[StopOut] = []


# ── Trip ────────────────────────────────────────────────
class TripOut(ORMModel):
    id: str
    tenant_id: str
    service_definition_id: str
    service_date: str
    driver_id: str | None
    vehicle_id: str | None
    planned_start_at: datetime | None
    actual_start_at: datetime | None
    planned_end_at: datetime | None
    actual_end_at: datetime | None
    current_stop_id: str | None
    next_stop_id: str | None
    status: str
    delay_minutes: int
    total_distance: float
    # Zenginleştirilmiş alanlar (join'lerle doldurulur; ham ORM'de varsayılan).
    service_name: str = ""
    direction: str = "morning"
    route_id: str = ""
    route_name: str = ""
    driver_name: str = ""
    vehicle_plate: str = ""
    passenger_count: int = 0
    stop_count: int = 0


class TripPassengerOut(ORMModel):
    id: str
    service_trip_id: str
    passenger_id: str
    stop_id: str
    boarding_status: str
    boarded_at: datetime | None
    driver_note: str | None
    # Zenginleştirilmiş alanlar.
    passenger_name: str = ""
    stop_name: str = ""


class BoardingUpdate(BaseModel):
    boarding_status: str
    driver_note: str | None = None


# ── Location ────────────────────────────────────────────
class LocationCreate(BaseModel):
    latitude: float
    longitude: float
    speed: float = 0
    heading: float = 0
    accuracy: float = 0


class LocationOut(ORMModel):
    id: str
    service_trip_id: str
    vehicle_id: str | None
    driver_id: str | None
    latitude: float
    longitude: float
    speed: float
    heading: float
    accuracy: float
    recorded_at: datetime


# ── ETA ─────────────────────────────────────────────────
class EtaOut(BaseModel):
    remaining_stops: int
    remaining_distance_meters: float
    eta_minutes: int
    planned_arrival_at: datetime
    estimated_arrival_at: datetime
    delay_minutes: int
