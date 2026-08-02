"""FastAPI bağımlılıkları: kimlik doğrulama, rol ve tenant izolasyonu."""
from collections.abc import Callable, Coroutine
from typing import Annotated, Any

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.roles import Role
from app.core.security import ACCESS_TOKEN, decode_token
from app.models.user import User

bearer = HTTPBearer(auto_error=False)

_CREDENTIALS_ERROR = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Geçersiz veya süresi dolmuş oturum.",
    headers={"WWW-Authenticate": "Bearer"},
)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """Access token'ı doğrular ve kullanıcıyı DB'den yükler.

    ÖNEMLİ: Rol ve tenant bilgisi token'a değil, DB'deki kullanıcı kaydına göre
    belirlenir. Böylece client tarafından manipüle edilen tenant/role değerlerine
    güvenilmez.
    """
    if credentials is None:
        raise _CREDENTIALS_ERROR
    try:
        payload = decode_token(credentials.credentials)
    except jwt.PyJWTError:
        raise _CREDENTIALS_ERROR
    if payload.get("type") != ACCESS_TOKEN:
        raise _CREDENTIALS_ERROR

    user_id = payload.get("sub")
    if not user_id:
        raise _CREDENTIALS_ERROR

    user = await db.get(User, user_id)
    if user is None or user.status == "disabled":
        raise _CREDENTIALS_ERROR
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
DbSession = Annotated[AsyncSession, Depends(get_db)]


def require_roles(*roles: Role) -> Callable[..., Coroutine[Any, Any, User]]:
    """Belirli rollere sahip kullanıcıları zorunlu kılan bağımlılık üreteci."""
    allowed = {r.value for r in roles}

    async def dependency(user: CurrentUser) -> User:
        if user.role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Bu işlem için yetkiniz yok.",
            )
        return user

    return dependency


def ensure_tenant_access(user: User, tenant_id: str | None) -> None:
    """Kullanıcının ilgili tenant'a erişimini doğrular (super_admin hariç)."""
    if user.role == Role.SUPER_ADMIN.value:
        return
    if tenant_id is None or user.tenant_id != tenant_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Bu kayda erişim yetkiniz yok.",
        )


async def load_users_by_email(db: AsyncSession, email: str) -> User | None:
    result = await db.execute(select(User).where(User.email == email.lower()))
    return result.scalar_one_or_none()
