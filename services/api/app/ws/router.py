"""WebSocket uç noktası — token doğrulaması + kanal bazlı yetkilendirme.

Her istemci yalnızca yetkili olduğu kanala abone olabilir. Yayınlar Redis
pub/sub üzerinden gelir; böylece birden çok API örneği ölçeklenebilir.
"""
from __future__ import annotations

import jwt
from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect
from sqlalchemy import select

from app.core.database import SessionLocal
from app.core.redis import get_redis
from app.core.roles import ADMIN_ROLES, Role
from app.core.security import ACCESS_TOKEN, decode_token
from app.models.service import ServiceTrip, TripPassenger
from app.models.user import User

router = APIRouter()


async def _authorize_channel(user: User, channel: str) -> bool:
    """Kullanıcının kanala erişip erişemeyeceğini belirler."""
    parts = channel.split(":")

    # user:{id}:notifications → yalnızca kendi kanalı
    if channel.startswith("user:") and channel.endswith(":notifications"):
        return len(parts) == 3 and parts[1] == user.id

    # tenant:{id}:operations → super_admin veya o tenant'ın yöneticisi
    if channel.startswith("tenant:") and channel.endswith(":operations"):
        tenant_id = parts[1]
        if user.role == Role.SUPER_ADMIN.value:
            return True
        return user.tenant_id == tenant_id and user.role in {r.value for r in ADMIN_ROLES}

    # trip:{id}:location → atanmış şoför, yolcusu olan kullanıcı, yönetici veya super_admin
    if channel.startswith("trip:") and channel.endswith(":location"):
        trip_id = parts[1]
        async with SessionLocal() as db:
            trip = await db.get(ServiceTrip, trip_id)
            if trip is None:
                return False
            if user.role == Role.SUPER_ADMIN.value:
                return True
            if user.tenant_id != trip.tenant_id:
                return False
            if user.role in {r.value for r in ADMIN_ROLES}:
                return True
            if user.role == Role.DRIVER.value:
                return trip.driver_id == user.id
            if user.role == Role.PASSENGER.value:
                result = await db.execute(
                    select(TripPassenger).where(
                        TripPassenger.service_trip_id == trip_id,
                        TripPassenger.passenger_id == user.id,
                    )
                )
                return result.scalar_one_or_none() is not None
        return False

    return False


async def _user_from_token(token: str) -> User | None:
    try:
        payload = decode_token(token)
    except jwt.PyJWTError:
        return None
    if payload.get("type") != ACCESS_TOKEN:
        return None
    async with SessionLocal() as db:
        return await db.get(User, payload.get("sub"))


@router.websocket("/ws")
async def ws_endpoint(
    websocket: WebSocket,
    channel: str = Query(...),
    token: str = Query(...),
) -> None:
    user = await _user_from_token(token)
    if user is None:
        await websocket.close(code=4401)  # Unauthorized
        return
    if not await _authorize_channel(user, channel):
        await websocket.close(code=4403)  # Forbidden
        return

    await websocket.accept()
    redis = get_redis()
    pubsub = redis.pubsub()
    await pubsub.subscribe(channel)
    try:
        async for message in pubsub.listen():
            if message.get("type") == "message":
                await websocket.send_text(message["data"])
    except WebSocketDisconnect:
        pass
    finally:
        await pubsub.unsubscribe(channel)
        await pubsub.aclose()
