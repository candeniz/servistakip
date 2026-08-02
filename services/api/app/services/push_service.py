"""Firebase Cloud Messaging push gönderimi (FCM v1, firebase-admin).

Servis hesabı anahtarı yoksa push sessizce devre dışı kalır; iş akışını bloklamaz.
"""
from __future__ import annotations

import asyncio
import logging
import os

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.user import DeviceToken

logger = logging.getLogger("push")

_initialized = False
_enabled = False


def _ensure_app() -> bool:
    """firebase-admin uygulamasını tembel başlatır. Başarılıysa True döner."""
    global _initialized, _enabled
    if _initialized:
        return _enabled
    _initialized = True
    path = settings.firebase_credentials
    if not path or not os.path.exists(path):
        logger.warning("FCM devre dışı: servis hesabı bulunamadı (%s)", path)
        _enabled = False
        return False
    try:
        import firebase_admin
        from firebase_admin import credentials

        if not firebase_admin._apps:  # noqa: SLF001 — tekil app kontrolü
            firebase_admin.initialize_app(credentials.Certificate(path))
        _enabled = True
        logger.info("FCM etkin (servis hesabı yüklendi).")
    except Exception as exc:  # noqa: BLE001
        logger.warning("FCM başlatılamadı: %s", exc)
        _enabled = False
    return _enabled


def _send_multicast_sync(tokens: list[str], title: str, body: str, data: dict[str, str]) -> int:
    """Senkron gönderim (thread havuzunda çağrılır). Gönderilen mesaj sayısını döndürür."""
    from firebase_admin import messaging

    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in data.items()},
    )
    response = messaging.send_each_for_multicast(message)
    return response.success_count


async def send_push(
    tokens: list[str], title: str, body: str, data: dict[str, str] | None = None
) -> int:
    """Verilen token'lara push gönderir. FCM kapalıysa 0 döner."""
    if not tokens or not _ensure_app():
        return 0
    try:
        return await asyncio.to_thread(_send_multicast_sync, tokens, title, body, data or {})
    except Exception as exc:  # noqa: BLE001 — push hatası iş akışını durdurmamalı
        logger.warning("Push gönderilemedi: %s", exc)
        return 0


async def push_to_users(
    db: AsyncSession,
    user_ids: list[str],
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> int:
    """Belirtilen kullanıcıların kayıtlı cihazlarına push gönderir."""
    if not user_ids:
        return 0
    result = await db.execute(
        select(DeviceToken.token).where(
            DeviceToken.user_id.in_(user_ids), DeviceToken.enabled.is_(True)
        )
    )
    tokens = [row[0] for row in result.all()]
    return await send_push(tokens, title, body, data)
