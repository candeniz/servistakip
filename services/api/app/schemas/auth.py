"""Kimlik doğrulama şemaları."""
from pydantic import BaseModel, EmailStr, Field


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1)


class RefreshRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str = Field(min_length=8)


class AuthTokens(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class AuthUser(BaseModel):
    id: str
    tenant_id: str | None
    first_name: str
    last_name: str
    email: EmailStr
    phone: str | None
    role: str
    status: str
    profile_photo: str | None
    tenant_name: str | None = None


class LoginResponse(BaseModel):
    tokens: AuthTokens
    user: AuthUser
