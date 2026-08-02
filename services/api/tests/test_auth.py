"""Kimlik doğrulama testleri."""
import pytest
from httpx import AsyncClient

from tests.conftest import auth_header, login

pytestmark = pytest.mark.asyncio


async def test_login_success(client: AsyncClient) -> None:
    resp = await client.post("/auth/login", json={"email": "sofor@demo.com", "password": "Demo123!"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["user"]["role"] == "driver"
    assert data["tokens"]["access_token"]


async def test_login_wrong_password(client: AsyncClient) -> None:
    resp = await client.post("/auth/login", json={"email": "sofor@demo.com", "password": "yanlis"})
    assert resp.status_code == 401


async def test_me_returns_current_user(client: AsyncClient) -> None:
    token = await login(client, "yolcu@demo.com")
    resp = await client.get("/auth/me", headers=auth_header(token))
    assert resp.status_code == 200
    assert resp.json()["email"] == "yolcu@demo.com"


async def test_me_requires_token(client: AsyncClient) -> None:
    resp = await client.get("/auth/me")
    assert resp.status_code == 401


async def test_refresh_rotates_token(client: AsyncClient) -> None:
    login_resp = await client.post("/auth/login", json={"email": "yolcu@demo.com", "password": "Demo123!"})
    refresh_token = login_resp.json()["tokens"]["refresh_token"]
    resp = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
    assert resp.status_code == 200
    assert resp.json()["access_token"]
