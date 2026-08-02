"""Redis pub/sub sarmalayıcısı — WebSocket yayınlarını ölçeklenebilir yapar."""
from __future__ import annotations

import json
from typing import Any

import redis.asyncio as aioredis

from app.core.config import settings

_redis: aioredis.Redis | None = None


def get_redis() -> aioredis.Redis:
    global _redis
    if _redis is None:
        _redis = aioredis.from_url(settings.redis_url, decode_responses=True)
    return _redis


async def publish(channel: str, event: str, payload: dict[str, Any]) -> None:
    """Bir kanala mesaj yayınlar.

    Redis erişilemezse (ör. testler veya geçici kesinti) hata yükseltmez;
    yayın en iyi çaba (best-effort) prensibiyle çalışır ve isteği bloklamaz.
    """
    message = json.dumps({"event": event, "channel": channel, "payload": payload})
    try:
        await get_redis().publish(channel, message)
    except Exception:  # noqa: BLE001 — yayın başarısızlığı iş akışını durdurmamalı
        pass


async def close_redis() -> None:
    global _redis
    if _redis is not None:
        await _redis.aclose()
        _redis = None
