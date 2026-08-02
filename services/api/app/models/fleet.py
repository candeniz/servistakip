"""Araç, güzergâh ve durak modelleri."""
from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin, UUIDMixin


class Vehicle(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "vehicles"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    plate_number: Mapped[str] = mapped_column(String(20), index=True)
    brand: Mapped[str] = mapped_column(String(80))
    model: Mapped[str] = mapped_column(String(80))
    year: Mapped[int] = mapped_column(Integer, default=2020)
    capacity: Mapped[int] = mapped_column(Integer, default=16)
    vehicle_type: Mapped[str] = mapped_column(String(40), default="minibus")
    inspection_expiry_date: Mapped[str | None] = mapped_column(String(20), nullable=True)
    insurance_expiry_date: Mapped[str | None] = mapped_column(String(20), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="active")


class Route(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "routes"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    name: Mapped[str] = mapped_column(String(200))
    direction: Mapped[str] = mapped_column(String(20), default="morning")
    start_location: Mapped[str] = mapped_column(String(200), default="")
    end_location: Mapped[str] = mapped_column(String(200), default="")
    # PostGIS ileride kullanılabilir; MVP'de kodlanmış polyline metni saklanır.
    encoded_polyline: Mapped[str | None] = mapped_column(String, nullable=True)
    estimated_distance: Mapped[float] = mapped_column(Float, default=0)  # metre
    estimated_duration: Mapped[int] = mapped_column(Integer, default=0)  # dakika
    status: Mapped[str] = mapped_column(String(20), default="active")


class Stop(UUIDMixin, Base):
    __tablename__ = "stops"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    route_id: Mapped[str] = mapped_column(String(36), ForeignKey("routes.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(200))
    latitude: Mapped[float] = mapped_column(Float)
    longitude: Mapped[float] = mapped_column(Float)
    order_index: Mapped[int] = mapped_column(Integer, default=0)
    planned_arrival_offset: Mapped[int] = mapped_column(Integer, default=0)  # dakika
    radius_meters: Mapped[int] = mapped_column(Integer, default=120)
    status: Mapped[str] = mapped_column(String(20), default="active")
