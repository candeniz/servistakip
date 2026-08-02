import '../../core/constants/statuses.dart';

/// Belirli bir tarihte gerçekleşen servis yolculuğu.
class ServiceTrip {
  const ServiceTrip({
    required this.id,
    required this.tenantId,
    required this.serviceName,
    required this.serviceDate,
    required this.direction,
    required this.routeId,
    required this.routeName,
    required this.driverId,
    required this.driverName,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.plannedStartAt,
    required this.actualStartAt,
    required this.plannedEndAt,
    required this.nextStopId,
    required this.status,
    required this.delayMinutes,
    required this.totalDistance,
    required this.passengerCount,
    required this.stopCount,
  });

  final String id;
  final String tenantId;
  final String serviceName;
  final String serviceDate;
  final RouteDirection direction;
  final String routeId;
  final String routeName;
  final String driverId;
  final String driverName;
  final String vehicleId;
  final String vehiclePlate;
  final DateTime? plannedStartAt;
  final DateTime? actualStartAt;
  final DateTime? plannedEndAt;
  final String? nextStopId;
  final TripStatus status;
  final int delayMinutes;
  final double totalDistance;
  final int passengerCount;
  final int stopCount;

  factory ServiceTrip.fromJson(Map<String, dynamic> json) => ServiceTrip(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        serviceName: json['service_name'] as String? ?? 'Servis',
        serviceDate: json['service_date'] as String? ?? '',
        direction: RouteDirection.fromValue(json['direction'] as String? ?? 'morning'),
        routeId: json['route_id'] as String? ?? '',
        routeName: json['route_name'] as String? ?? '',
        driverId: json['driver_id'] as String? ?? '',
        driverName: json['driver_name'] as String? ?? '',
        vehicleId: json['vehicle_id'] as String? ?? '',
        vehiclePlate: json['vehicle_plate'] as String? ?? '',
        plannedStartAt: _dt(json['planned_start_at']),
        actualStartAt: _dt(json['actual_start_at']),
        plannedEndAt: _dt(json['planned_end_at']),
        nextStopId: json['next_stop_id'] as String?,
        status: TripStatus.fromValue(json['status'] as String? ?? 'scheduled'),
        delayMinutes: (json['delay_minutes'] as num?)?.toInt() ?? 0,
        totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0,
        passengerCount: (json['passenger_count'] as num?)?.toInt() ?? 0,
        stopCount: (json['stop_count'] as num?)?.toInt() ?? 0,
      );

  static DateTime? _dt(Object? v) => v == null ? null : DateTime.tryParse(v as String);
}

/// Yolculuktaki yolcu kaydı.
class TripPassenger {
  TripPassenger({
    required this.id,
    required this.serviceTripId,
    required this.passengerId,
    required this.passengerName,
    required this.stopId,
    required this.stopName,
    required this.boardingStatus,
    required this.boardedAt,
  });

  final String id;
  final String serviceTripId;
  final String passengerId;
  final String passengerName;
  final String stopId;
  final String stopName;
  BoardingStatus boardingStatus;
  DateTime? boardedAt;

  TripPassenger copyWith({BoardingStatus? boardingStatus, DateTime? boardedAt}) => TripPassenger(
        id: id,
        serviceTripId: serviceTripId,
        passengerId: passengerId,
        passengerName: passengerName,
        stopId: stopId,
        stopName: stopName,
        boardingStatus: boardingStatus ?? this.boardingStatus,
        boardedAt: boardedAt ?? this.boardedAt,
      );

  factory TripPassenger.fromJson(Map<String, dynamic> json) => TripPassenger(
        id: json['id'] as String,
        serviceTripId: json['service_trip_id'] as String,
        passengerId: json['passenger_id'] as String,
        passengerName: json['passenger_name'] as String? ?? '',
        stopId: json['stop_id'] as String,
        stopName: json['stop_name'] as String? ?? '',
        boardingStatus: BoardingStatus.fromValue(json['boarding_status'] as String? ?? 'expected'),
        boardedAt: json['boarded_at'] == null ? null : DateTime.tryParse(json['boarded_at'] as String),
      );
}
