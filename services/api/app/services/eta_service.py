"""Sunucu tarafı ETA hesaplama — MockETAProvider.

ETAProvider arayüzü sayesinde ileride Google/Mapbox sağlayıcıları eklenebilir.
"""
from __future__ import annotations

import math
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from app.models.fleet import Stop

EARTH_RADIUS_M = 6_371_000


def haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2) ** 2
    )
    return 2 * EARTH_RADIUS_M * math.asin(min(1.0, math.sqrt(a)))


@dataclass
class EtaInput:
    vehicle_lat: float
    vehicle_lng: float
    stops: list[Stop]  # sıralı
    next_stop_index: int
    target_stop_index: int
    average_speed_kmh: float = 32.0
    dwell_seconds_per_stop: int = 45
    planned_arrival_at: datetime | None = None


@dataclass
class EtaResult:
    remaining_stops: int
    remaining_distance_meters: float
    eta_minutes: int
    planned_arrival_at: datetime
    estimated_arrival_at: datetime
    delay_minutes: int


class ETAProvider(ABC):
    name: str = "base"

    @abstractmethod
    def calculate(self, data: EtaInput) -> EtaResult: ...


class MockETAProvider(ETAProvider):
    """Harici API'siz basit ETA hesaplayıcı (mobil MockETAProvider ile aynı mantık)."""

    name = "mock"

    def calculate(self, data: EtaInput) -> EtaResult:
        now = datetime.now(timezone.utc)
        target = min(max(data.target_stop_index, data.next_stop_index), len(data.stops) - 1)

        distance = 0.0
        if data.next_stop_index <= target:
            first = data.stops[data.next_stop_index]
            distance += haversine_m(data.vehicle_lat, data.vehicle_lng, first.latitude, first.longitude)
            for i in range(data.next_stop_index, target):
                a, b = data.stops[i], data.stops[i + 1]
                distance += haversine_m(a.latitude, a.longitude, b.latitude, b.longitude)

        remaining_stops = max(0, target - data.next_stop_index + 1)
        speed_ms = max(1.0, data.average_speed_kmh * 1000 / 3600)
        drive_seconds = distance / speed_ms
        dwell_seconds = max(0, remaining_stops - 1) * data.dwell_seconds_per_stop
        eta_seconds = drive_seconds + dwell_seconds

        estimated = now + timedelta(seconds=eta_seconds)
        planned = data.planned_arrival_at or estimated
        if planned.tzinfo is None:
            planned = planned.replace(tzinfo=timezone.utc)
        delay_minutes = max(0, round((estimated - planned).total_seconds() / 60))

        return EtaResult(
            remaining_stops=remaining_stops,
            remaining_distance_meters=round(distance, 1),
            eta_minutes=max(0, round(eta_seconds / 60)),
            planned_arrival_at=planned,
            estimated_arrival_at=estimated,
            delay_minutes=delay_minutes,
        )


def get_eta_provider(kind: str = "mock") -> ETAProvider:
    # İleride: google/mapbox sağlayıcıları burada seçilir.
    return MockETAProvider()
