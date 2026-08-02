import '../../core/constants/statuses.dart';
import 'stop.dart';

/// Güzergâh (durak listesiyle birlikte).
class ServiceRoute {
  const ServiceRoute({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.direction,
    required this.startLocation,
    required this.endLocation,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.stops,
  });

  final String id;
  final String tenantId;
  final String name;
  final RouteDirection direction;
  final String startLocation;
  final String endLocation;
  final double estimatedDistance;
  final int estimatedDuration;
  final List<Stop> stops;

  int get stopCount => stops.length;

  factory ServiceRoute.fromJson(Map<String, dynamic> json) => ServiceRoute(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        name: json['name'] as String,
        direction: RouteDirection.fromValue(json['direction'] as String? ?? 'morning'),
        startLocation: json['start_location'] as String? ?? '',
        endLocation: json['end_location'] as String? ?? '',
        estimatedDistance: (json['estimated_distance'] as num?)?.toDouble() ?? 0,
        estimatedDuration: (json['estimated_duration'] as num?)?.toInt() ?? 0,
        stops: ((json['stops'] as List?) ?? [])
            .map((e) => Stop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
