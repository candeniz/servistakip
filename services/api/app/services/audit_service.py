"""Denetim kaydı yardımcıları."""
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.misc import AuditLog


async def record_audit(
    db: AsyncSession,
    *,
    tenant_id: str | None,
    user_id: str | None,
    action: str,
    entity_type: str,
    entity_id: str | None = None,
    ip_address: str | None = None,
) -> None:
    """Hassas veri içermeyen denetim kaydı oluşturur."""
    log = AuditLog(
        tenant_id=tenant_id,
        user_id=user_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        ip_address=ip_address,
        created_at=datetime.now(timezone.utc),
    )
    db.add(log)
