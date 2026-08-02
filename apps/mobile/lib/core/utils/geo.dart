import 'dart:math';

/// Basit coğrafi hesaplamalar (harici bağımlılık yok).
class LatLngPoint {
  const LatLngPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

const double _earthRadiusM = 6371000;

double _toRad(double deg) => deg * pi / 180;

/// İki nokta arası büyük daire mesafesi (metre).
double haversineMeters(LatLngPoint a, LatLngPoint b) {
  final dLat = _toRad(b.latitude - a.latitude);
  final dLng = _toRad(b.longitude - a.longitude);
  final lat1 = _toRad(a.latitude);
  final lat2 = _toRad(b.latitude);
  final h = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLng / 2), 2);
  return 2 * _earthRadiusM * asin(min(1.0, sqrt(h.toDouble())));
}

/// a'dan b'ye yön (0-360 derece, kuzey = 0).
double bearingDeg(LatLngPoint a, LatLngPoint b) {
  final lat1 = _toRad(a.latitude);
  final lat2 = _toRad(b.latitude);
  final dLng = _toRad(b.longitude - a.longitude);
  final y = sin(dLng) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

/// Nokta, merkezin verilen yarıçapı (metre) içinde mi? (geofence).
bool isWithinRadius(LatLngPoint point, LatLngPoint center, double radiusMeters) =>
    haversineMeters(point, center) <= radiusMeters;
