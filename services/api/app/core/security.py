"""Şifre hashleme ve JWT üretimi/doğrulaması."""
from datetime import datetime, timedelta, timezone
from typing import Any

import bcrypt
import jwt

from app.core.config import settings

ACCESS_TOKEN = "access"
REFRESH_TOKEN = "refresh"

# bcrypt en fazla 72 bayt işler; daha uzun şifreler güvenli biçimde kırpılır.
_BCRYPT_MAX_BYTES = 72


def hash_password(password: str) -> str:
    payload = password.encode("utf-8")[:_BCRYPT_MAX_BYTES]
    return bcrypt.hashpw(payload, bcrypt.gensalt()).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    payload = plain.encode("utf-8")[:_BCRYPT_MAX_BYTES]
    try:
        return bcrypt.checkpw(payload, hashed.encode("utf-8"))
    except ValueError:
        return False


def _create_token(subject: str, token_type: str, expires_delta: timedelta, extra: dict[str, Any]) -> str:
    now = datetime.now(timezone.utc)
    payload: dict[str, Any] = {
        "sub": subject,
        "type": token_type,
        "iat": now,
        "exp": now + expires_delta,
        **extra,
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(user_id: str, role: str, tenant_id: str | None) -> str:
    # tenant_id ve role token içine gömülür; ancak yetki her istekte DB ile doğrulanır.
    return _create_token(
        user_id,
        ACCESS_TOKEN,
        timedelta(minutes=settings.access_token_expire_minutes),
        {"role": role, "tenant_id": tenant_id},
    )


def create_refresh_token(user_id: str) -> str:
    return _create_token(
        user_id,
        REFRESH_TOKEN,
        timedelta(days=settings.refresh_token_expire_days),
        {},
    )


def decode_token(token: str) -> dict[str, Any]:
    """Token'ı çözer; süre/format hatasında jwt istisnası fırlatır."""
    return jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
