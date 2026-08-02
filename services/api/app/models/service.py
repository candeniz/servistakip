"""Servis tanımı, yolculuk, yolcu ve konum modelleri."""
from datetime import datetime

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin, UUIDMixin


class ServiceDefinition(UUIDMixin, TimestampMixin, Base):
    """Tekrar eden servis planı."""
    __tablename__ = "service_definitions"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    name: Mapped[str] = mapped_column(String(200))
    route_id: Mapped[str] = mapped_column(String(36), ForeignKey("routes.id"))
    vehicle_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("vehicles.id"), nullable=True)
    driver_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    direction: Mapped[str] = mapped_column(String(20), default="morning")
    start_time: Mapped[str] = mapped_column(String(10), default="06:30")  # HH:MM
    # Aktif günler: "1,2,3,4,5" (Pzt-Cum)
    active_days: Mapped[str] = mapped_column(String(20), default="1,2,3,4,5")
    status: Mapped[str] = mapped_column(String(20), default="active")


class ServiceTrip(UUIDMixin, TimestampMixin, Base):
    """Belirli bir tarihteki gerçek yolculuk."""
    __tablename__ = "service_trips"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    service_definition_id: Mapped[str] = mapped_column(String(36), ForeignKey("service_definitions.id"))
    service_date: Mapped[str] = mapped_column(String(20), index=True)  # YYYY-MM-DD
    driver_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True, index=True)
    vehicle_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("vehicles.id"), nullable=True)
    planned_start_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    actual_start_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    planned_end_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    actual_end_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    current_stop_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    next_stop_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="scheduled", index=True)
    delay_minutes: Mapped[int] = mapped_column(Integer, default=0)
    total_distance: Mapped[float] = mapped_column(Float, default=0)


class TripPassenger(UUIDMixin, Base):
    __tablename__ = "trip_passengers"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    service_trip_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("service_trips.id", ondelete="CASCADE"), index=True
    )
    passenger_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True)
    stop_id: Mapped[str] = mapped_column(String(36), ForeignKey("stops.id"))
    boarding_status: Mapped[str] = mapped_column(String(20), default="expected")
    boarded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    driver_note: Mapped[str | None] = mapped_column(String(500), nullable=True)


class VehicleLocation(UUIDMixin, Base):
    __tablename__ = "vehicle_locations"

    tenant_id: Mapped[str] = mapped_column(String(36), index=True)
    service_trip_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("service_trips.id", ondelete="CASCADE"), index=True
    )
    vehicle_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    driver_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    latitude: Mapped[float] = mapped_column(Float)
    longitude: Mapped[float] = mapped_column(Float)
    speed: Mapped[float] = mapped_column(Float, default=0)
    heading: Mapped[float] = mapped_column(Float, default=0)
    accuracy: Mapped[float] = mapped_column(Float, default=0)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
