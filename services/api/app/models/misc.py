"""İzin, bildirim, duyuru, olay ve denetim kaydı modelleri."""
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.mixins import TimestampMixin, UUIDMixin


class AbsenceRequest(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "absence_requests"

    tenant_id: Mapped[str] = mapped_column(String(36), index=True)
    passenger_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True)
    start_date: Mapped[str] = mapped_column(String(20))
    end_date: Mapped[str] = mapped_column(String(20))
    morning_absent: Mapped[bool] = mapped_column(Boolean, default=False)
    evening_absent: Mapped[bool] = mapped_column(Boolean, default=False)
    reason: Mapped[str | None] = mapped_column(String(500), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="approved")


class Notification(UUIDMixin, Base):
    __tablename__ = "notifications"

    tenant_id: Mapped[str] = mapped_column(String(36), index=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(200))
    message: Mapped[str] = mapped_column(String(500))
    type: Mapped[str] = mapped_column(String(40))
    data: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON metni
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class Announcement(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "announcements"

    tenant_id: Mapped[str] = mapped_column(String(36), index=True)
    created_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    title: Mapped[str] = mapped_column(String(200))
    content: Mapped[str] = mapped_column(Text)
    target_type: Mapped[str] = mapped_column(String(30), default="all")  # all | role | users
    target_ids: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON metni
    scheduled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="published")


class Incident(UUIDMixin, Base):
    __tablename__ = "incidents"

    tenant_id: Mapped[str] = mapped_column(String(36), index=True)
    service_trip_id: Mapped[str] = mapped_column(String(36), ForeignKey("service_trips.id"), index=True)
    driver_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    vehicle_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    incident_type: Mapped[str] = mapped_column(String(30))
    description: Mapped[str] = mapped_column(Text)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="open")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class AuditLog(UUIDMixin, Base):
    __tablename__ = "audit_logs"

    tenant_id: Mapped[str | None] = mapped_column(String(36), nullable=True, index=True)
    user_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    action: Mapped[str] = mapped_column(String(80))
    entity_type: Mapped[str] = mapped_column(String(60))
    entity_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    old_values: Mapped[str | None] = mapped_column(Text, nullable=True)
    new_values: Mapped[str | None] = mapped_column(Text, nullable=True)
    ip_address: Mapped[str | None] = mapped_column(String(60), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
