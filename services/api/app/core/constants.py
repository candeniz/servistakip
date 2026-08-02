"""WebSocket kanal ve olay sabitleri (mobil @servis/shared ile eşleşir)."""

WS_EVENTS = {
    "LOCATION_UPDATE": "location_update",
    "ETA_UPDATE": "eta_update",
    "TRIP_STATUS": "trip_status",
    "STOP_ARRIVED": "stop_arrived",
    "STOP_DEPARTED": "stop_departed",
    "PASSENGER_UPDATE": "passenger_update",
    "NOTIFICATION": "notification",
    "CONNECTION_LOST": "connection_lost",
}


def ws_tenant_operations(tenant_id: str) -> str:
    return f"tenant:{tenant_id}:operations"


def ws_trip_location(trip_id: str) -> str:
    return f"trip:{trip_id}:location"


def ws_user_notifications(user_id: str) -> str:
    return f"user:{user_id}:notifications"


# Konum kabul eşiği (metre) — bundan kötü doğruluk reddedilir.
MAX_ACCEPTABLE_ACCURACY_M = 60
