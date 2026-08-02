"""FastAPI uygulama giriş noktası."""
import logging
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.router import api_router
from app.core.config import settings
from app.core.redis import close_redis
from app.ws.router import router as ws_router

logger = logging.getLogger("servis")


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncGenerator[None, None]:
    # Başlangıç kancası (gerekirse): şimdilik yok.
    yield
    # Kapanışta Redis bağlantısını temizle.
    await close_redis()


app = FastAPI(
    title="Servis Takip API",
    version="0.1.0",
    description="Çok kiracılı, rol bazlı personel servisi takip platformu.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    # Sistem içi detayları istemciye sızdırma; sadece logla.
    logger.exception("Beklenmeyen hata: %s", exc)
    return JSONResponse(status_code=500, content={"detail": "Sunucu hatası oluştu."})


@app.get("/health", tags=["system"])
async def health() -> dict:
    return {"status": "ok", "env": settings.api_env}


# REST ve WebSocket router'ları
app.include_router(api_router)
app.include_router(ws_router)
