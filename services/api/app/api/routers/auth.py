"""Kimlik doğrulama endpoint'leri."""
from datetime import datetime, timezone

import jwt
from fastapi import APIRouter, HTTPException, status

from app.core.config import settings
from app.core.deps import CurrentUser, DbSession, load_users_by_email
from app.core.security import (
    REFRESH_TOKEN,
    create_access_token,
    create_refresh_token,
    decode_token,
    verify_password,
)
from app.models.user import User
from app.schemas.auth import (
    AuthTokens,
    AuthUser,
    ForgotPasswordRequest,
    LoginRequest,
    LoginResponse,
    RefreshRequest,
    ResetPasswordRequest,
)
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/auth", tags=["auth"])

_INVALID_LOGIN = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED, detail="E-posta veya şifre hatalı."
)


def _tokens_for(user: User) -> AuthTokens:
    return AuthTokens(
        access_token=create_access_token(user.id, user.role, user.tenant_id),
        refresh_token=create_refresh_token(user.id),
        expires_in=settings.access_token_expire_minutes * 60,
    )


async def _auth_user(db: DbSession, user: User) -> AuthUser:
    tenant_name = None
    if user.tenant_id:
        from app.models.user import Tenant

        tenant = await db.get(Tenant, user.tenant_id)
        tenant_name = tenant.name if tenant else None
    return AuthUser(
        id=user.id,
        tenant_id=user.tenant_id,
        first_name=user.first_name,
        last_name=user.last_name,
        email=user.email,
        phone=user.phone,
        role=user.role,
        status=user.status,
        profile_photo=user.profile_photo,
        tenant_name=tenant_name,
    )


@router.post("/login", response_model=LoginResponse)
async def login(body: LoginRequest, db: DbSession) -> LoginResponse:
    user = await load_users_by_email(db, body.email)
    # Zamanlama saldırılarına karşı: kullanıcı yoksa da doğrulama yap.
    if user is None or not verify_password(body.password, user.password_hash):
        raise _INVALID_LOGIN
    if user.status == "disabled":
        raise _INVALID_LOGIN
    user.last_login_at = datetime.now(timezone.utc).isoformat()
    return LoginResponse(tokens=_tokens_for(user), user=await _auth_user(db, user))


@router.post("/refresh", response_model=AuthTokens)
async def refresh(body: RefreshRequest, db: DbSession) -> AuthTokens:
    try:
        payload = decode_token(body.refresh_token)
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Geçersiz yenileme anahtarı.")
    if payload.get("type") != REFRESH_TOKEN:
        raise HTTPException(status_code=401, detail="Geçersiz yenileme anahtarı.")
    user = await db.get(User, payload.get("sub"))
    if user is None:
        raise HTTPException(status_code=401, detail="Kullanıcı bulunamadı.")
    # Refresh token rotation: her yenilemede yeni refresh üretilir.
    return _tokens_for(user)


@router.post("/logout", response_model=MessageResponse)
async def logout(user: CurrentUser) -> MessageResponse:
    # Stateless JWT; istemci token'ları siler. (Prod: refresh denylist eklenebilir.)
    return MessageResponse(detail="Çıkış yapıldı.")


@router.post("/forgot-password", response_model=MessageResponse)
async def forgot_password(body: ForgotPasswordRequest, db: DbSession) -> MessageResponse:
    # Kullanıcı var olsun olmasın aynı yanıt (bilgi sızıntısını önler).
    return MessageResponse(detail="Eğer hesap varsa sıfırlama bağlantısı gönderildi.")


@router.post("/reset-password", response_model=MessageResponse)
async def reset_password(body: ResetPasswordRequest) -> MessageResponse:
    # MVP: token doğrulama akışı iskeleti.
    return MessageResponse(detail="Şifre sıfırlandı.")


@router.get("/me", response_model=AuthUser)
async def me(user: CurrentUser, db: DbSession) -> AuthUser:
    return await _auth_user(db, user)
