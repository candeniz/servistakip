"""Uygulama yapılandırması (ortam değişkenlerinden)."""
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Ortam
    api_env: str = "development"

    # Veritabanı (async uygulama sürücüsü)
    database_url: str = "postgresql+asyncpg://servis:servis_dev_pw@localhost:5432/servis_takip"

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # JWT
    jwt_secret_key: str = "change-me-in-production-please-32chars-min"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30

    # CORS (virgülle ayrılmış)
    cors_origins: str = "http://localhost:8081,http://localhost:19006"

    # ETA sağlayıcı
    eta_provider: str = "mock"

    # Firebase Cloud Messaging (push). Servis hesabı JSON yolu; dosya yoksa
    # push gönderimi sessizce devre dışı kalır.
    firebase_credentials: str = "secrets/firebase-service-account.json"

    # Demo veri
    seed_demo_data: bool = True

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
