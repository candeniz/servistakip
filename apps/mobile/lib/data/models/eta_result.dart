/// ETA hesaplama sonucu.
class EtaResult {
  const EtaResult({
    required this.remainingStops,
    required this.remainingDistanceMeters,
    required this.etaMinutes,
    required this.plannedArrivalAt,
    required this.estimatedArrivalAt,
    required this.delayMinutes,
  });

  final int remainingStops;
  final double remainingDistanceMeters;
  final int etaMinutes;
  final DateTime plannedArrivalAt;
  final DateTime estimatedArrivalAt;
  final int delayMinutes;

  factory EtaResult.fromJson(Map<String, dynamic> json) => EtaResult(
        remainingStops: (json['remaining_stops'] as num).toInt(),
        remainingDistanceMeters: (json['remaining_distance_meters'] as num).toDouble(),
        etaMinutes: (json['eta_minutes'] as num).toInt(),
        plannedArrivalAt: DateTime.parse(json['planned_arrival_at'] as String),
        estimatedArrivalAt: DateTime.parse(json['estimated_arrival_at'] as String),
        delayMinutes: (json['delay_minutes'] as num).toInt(),
      );
}
