"""Servis yaşam döngüsü ve yolcu biniş durumu testleri."""
import pytest
from httpx import AsyncClient

from tests.conftest import PASSENGER_ID, TRIP_ID, auth_header, login

pytestmark = pytest.mark.asyncio


async def test_driver_can_start_and_complete_trip(client: AsyncClient) -> None:
    token = await login(client, "sofor@demo.com")
    start = await client.post(f"/trips/{TRIP_ID}/start", headers=auth_header(token))
    assert start.status_code == 200
    assert start.json()["status"] == "active"

    complete = await client.post(f"/trips/{TRIP_ID}/complete", headers=auth_header(token))
    assert complete.status_code == 200
    assert complete.json()["status"] == "completed"


async def test_driver_updates_boarding_status(client: AsyncClient) -> None:
    token = await login(client, "sofor@demo.com")
    resp = await client.patch(
        f"/trips/{TRIP_ID}/passengers/{PASSENGER_ID}",
        headers=auth_header(token),
        json={"boarding_status": "boarded"},
    )
    assert resp.status_code == 200
    assert resp.json()["boarding_status"] == "boarded"


async def test_post_location_only_by_assigned_driver(client: AsyncClient) -> None:
    driver_token = await login(client, "sofor@demo.com")
    # Servisi aktif yap
    await client.post(f"/trips/{TRIP_ID}/start", headers=auth_header(driver_token))

    ok = await client.post(
        f"/trips/{TRIP_ID}/locations",
        headers=auth_header(driver_token),
        json={"latitude": 41.0, "longitude": 28.6, "speed": 30, "heading": 90, "accuracy": 10},
    )
    assert ok.status_code == 201

    latest = await client.get(f"/trips/{TRIP_ID}/latest-location", headers=auth_header(driver_token))
    assert latest.status_code == 200
    assert latest.json()["latitude"] == 41.0


async def test_bad_accuracy_location_rejected(client: AsyncClient) -> None:
    driver_token = await login(client, "sofor@demo.com")
    await client.post(f"/trips/{TRIP_ID}/start", headers=auth_header(driver_token))
    resp = await client.post(
        f"/trips/{TRIP_ID}/locations",
        headers=auth_header(driver_token),
        json={"latitude": 41.0, "longitude": 28.6, "accuracy": 500},
    )
    assert resp.status_code == 422


async def test_passenger_cannot_post_location(client: AsyncClient) -> None:
    driver_token = await login(client, "sofor@demo.com")
    await client.post(f"/trips/{TRIP_ID}/start", headers=auth_header(driver_token))
    pax_token = await login(client, "yolcu@demo.com")
    resp = await client.post(
        f"/trips/{TRIP_ID}/locations",
        headers=auth_header(pax_token),
        json={"latitude": 41.0, "longitude": 28.6, "accuracy": 10},
    )
    assert resp.status_code == 403
