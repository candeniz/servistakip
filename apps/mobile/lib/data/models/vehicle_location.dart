import '../../core/utils/geo.dart';

/// Araç konum okuması (backend LocationOut / WS LOCATION_UPDATE payload'ı).
class VehicleLocationDto {
  const VehicleLocationDto({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final DateTime? recordedAt;

  LatLngPoint get point => LatLngPoint(latitude, longitude);

  /// Hız km/s cinsine çevrilir (backend m/s gönderir).
  double get speedKmh => speed * 3.6;

  factory VehicleLocationDto.fromJson(Map<String, dynamic> json) => VehicleLocationDto(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        speed: (json['speed'] as num?)?.toDouble() ?? 0,
        heading: (json['heading'] as num?)?.toDouble() ?? 0,
        recordedAt: json['recorded_at'] == null ? null : DateTime.tryParse(json['recorded_at'] as String),
      );
}
