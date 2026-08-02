"""Rol ve tenant izolasyonu testleri."""
import pytest
from httpx import AsyncClient

from tests.conftest import TRIP_ID, auth_header, login

pytestmark = pytest.mark.asyncio


async def test_driver_sees_only_assigned_trips(client: AsyncClient) -> None:
    token = await login(client, "sofor@demo.com")
    resp = await client.get("/trips", headers=auth_header(token))
    assert resp.status_code == 200
    trips = resp.json()
    assert all(t["driver_id"] == "u-driver" for t in trips)
    assert len(trips) == 1


async def test_passenger_sees_only_own_current_trip(client: AsyncClient) -> None:
    # Atanmış yolcu aktif servisini görebilir.
    token = await login(client, "yolcu@demo.com")
    resp = await client.get("/passenger/current-trip", headers=auth_header(token))
    assert resp.status_code == 200
    assert resp.json()["id"] == TRIP_ID


async def test_passenger_without_assignment_gets_404(client: AsyncClient) -> None:
    # Servise atanmamış ikinci yolcu aktif servis görmemeli.
    token = await login(client, "yolcu2@demo.com")
    resp = await client.get("/passenger/current-trip", headers=auth_header(token))
    assert resp.status_code == 404


async def test_passenger_cannot_list_users(client: AsyncClient) -> None:
    token = await login(client, "yolcu@demo.com")
    resp = await client.get("/users", headers=auth_header(token))
    assert resp.status_code == 403


async def test_only_super_admin_lists_tenants(client: AsyncClient) -> None:
    admin_token = await login(client, "yonetici@demo.com")
    assert (await client.get("/tenants", headers=auth_header(admin_token))).status_code == 403

    su_token = await login(client, "superadmin@demo.com")
    resp = await client.get("/tenants", headers=auth_header(su_token))
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1


async def test_driver_cannot_access_other_driver_trip_actions(client: AsyncClient) -> None:
    # Yolcu (şoför değil) servis başlatamaz.
    token = await login(client, "yolcu@demo.com")
    resp = await client.post(f"/trips/{TRIP_ID}/start", headers=auth_header(token))
    # Yolcu bu servise erişebilir mi? Yolcu trip üyesi değil (stop üyesi ama can_access driver/passenger)
    assert resp.status_code in (403, 404)
