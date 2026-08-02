"""Tenant, User ve profil modelleri."""
from sqlalchemy import Boolean, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin, UUIDMixin


class Tenant(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "tenants"

    name: Mapped[str] = mapped_column(String(200))
    company_code: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    logo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    primary_color: Mapped[str | None] = mapped_column(String(20), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="active")
    package_id: Mapped[str | None] = mapped_column(String(50), nullable=True)
    user_limit: Mapped[int] = mapped_column(Integer, default=50)
    vehicle_limit: Mapped[int] = mapped_column(Integer, default=10)


class User(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "users"

    # super_admin için tenant_id NULL olabilir.
    tenant_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("tenants.id", ondelete="CASCADE"), nullable=True, index=True
    )
    first_name: Mapped[str] = mapped_column(String(100))
    last_name: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(30), nullable=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(30), index=True)
    status: Mapped[str] = mapped_column(String(20), default="active")
    profile_photo: Mapped[str | None] = mapped_column(String(500), nullable=True)
    last_login_at: Mapped[str | None] = mapped_column(String(40), nullable=True)


class EmployeeProfile(UUIDMixin, Base):
    __tablename__ = "employee_profiles"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    employee_number: Mapped[str | None] = mapped_column(String(50), nullable=True)
    department_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    default_morning_trip_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    default_evening_trip_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    morning_stop_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    evening_stop_id: Mapped[str | None] = mapped_column(String(36), nullable=True)


class DriverProfile(UUIDMixin, Base):
    __tablename__ = "driver_profiles"

    tenant_id: Mapped[str] = mapped_column(String(36), ForeignKey("tenants.id"), index=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    license_number: Mapped[str | None] = mapped_column(String(50), nullable=True)
    license_expiry_date: Mapped[str | None] = mapped_column(String(20), nullable=True)
    assigned_vehicle_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="active")


class DeviceToken(UUIDMixin, TimestampMixin, Base):
    """Expo push token'ları — bildirim gönderimi için."""
    __tablename__ = "device_tokens"

    tenant_id: Mapped[str | None] = mapped_column(String(36), nullable=True, index=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True)
    token: Mapped[str] = mapped_column(String(255), unique=True)
    platform: Mapped[str] = mapped_column(String(20), default="unknown")
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
