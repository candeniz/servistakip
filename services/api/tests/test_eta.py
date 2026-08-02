"""Sunucu tarafı ETA hesaplama testleri."""
from datetime import datetime, timezone

from app.models.fleet import Stop
from app.services.eta_service import EtaInput, MockETAProvider


def _stops() -> list[Stop]:
    coords = [(41.0, 28.6), (41.01, 28.62), (41.02, 28.64), (41.03, 28.66), (41.04, 28.68)]
    return [
        Stop(
            id=f"s-{i}", tenant_id="t", route_id="r", name=f"D{i}",
            latitude=lat, longitude=lng, order_index=i,
            planned_arrival_offset=i * 6, radius_meters=120, status="active",
        )
        for i, (lat, lng) in enumerate(coords)
    ]


def test_remaining_stops_count() -> None:
    provider = MockETAProvider()
    stops = _stops()
    result = provider.calculate(
        EtaInput(
            vehicle_lat=stops[0].latitude,
            vehicle_lng=stops[0].longitude,
            stops=stops,
            next_stop_index=1,
            target_stop_index=4,
            planned_arrival_at=datetime.now(timezone.utc),
        )
    )
    assert result.remaining_stops == 4
    assert result.remaining_distance_meters > 0
    assert result.eta_minutes >= 0


def test_eta_decreases_as_vehicle_advances() -> None:
    provider = MockETAProvider()
    stops = _stops()
    far = provider.calculate(
        EtaInput(vehicle_lat=stops[0].latitude, vehicle_lng=stops[0].longitude,
                 stops=stops, next_stop_index=1, target_stop_index=4)
    )
    near = provider.calculate(
        EtaInput(vehicle_lat=stops[3].latitude, vehicle_lng=stops[3].longitude,
                 stops=stops, next_stop_index=4, target_stop_index=4)
    )
    assert near.remaining_distance_meters < far.remaining_distance_meters
    assert near.remaining_stops < far.remaining_stops
