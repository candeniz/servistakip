"""Cihaz push token kaydı (Expo)."""
from fastapi import APIRouter
from pydantic import BaseModel
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession
from app.models.user import DeviceToken
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/notifications", tags=["notifications"])


class DeviceTokenBody(BaseModel):
    token: str
    platform: str = "unknown"


@router.post("/device-tokens", response_model=MessageResponse)
async def register_device_token(body: DeviceTokenBody, db: DbSession, current: CurrentUser) -> MessageResponse:
    # Aynı token varsa güncelle, yoksa oluştur (idempotent).
    existing = await db.execute(select(DeviceToken).where(DeviceToken.token == body.token))
    token = existing.scalar_one_or_none()
    if token:
        token.user_id = current.id
        token.tenant_id = current.tenant_id
        token.platform = body.platform
        token.enabled = True
    else:
        db.add(
            DeviceToken(
                user_id=current.id,
                tenant_id=current.tenant_id,
                token=body.token,
                platform=body.platform,
                enabled=True,
            )
        )
    return MessageResponse(detail="Cihaz kaydedildi.")
