import '../../core/utils/geo.dart';

/// Güzergâh üzerindeki durak.
class Stop {
  const Stop({
    required this.id,
    required this.tenantId,
    required this.routeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.orderIndex,
    required this.plannedArrivalOffset,
    required this.radiusMeters,
  });

  final String id;
  final String tenantId;
  final String routeId;
  final String name;
  final double latitude;
  final double longitude;
  final int orderIndex;
  final int plannedArrivalOffset; // dakika
  final int radiusMeters;

  LatLngPoint get point => LatLngPoint(latitude, longitude);

  factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        routeId: json['route_id'] as String,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
        plannedArrivalOffset: (json['planned_arrival_offset'] as num?)?.toInt() ?? 0,
        radiusMeters: (json['radius_meters'] as num?)?.toInt() ?? 120,
      );
}
