import '../../core/utils/geo.dart';
import '../models/eta_result.dart';
import '../models/stop.dart';

/// ETA hesaplaması için girdi.
class EtaInput {
  const EtaInput({
    required this.vehicleLocation,
    required this.stops,
    required this.nextStopIndex,
    required this.targetStopIndex,
    required this.plannedArrivalAt,
    this.averageSpeedKmh = 32,
    this.dwellSecondsPerStop = 45,
    this.now,
  });

  final LatLngPoint vehicleLocation;
  final List<Stop> stops;
  final int nextStopIndex;
  final int targetStopIndex;
  final DateTime plannedArrivalAt;
  final double averageSpeedKmh;
  final int dwellSecondsPerStop;
  final DateTime? now;
}

/// ETA sağlayıcı arayüzü. MVP'de MockEtaProvider kullanılır; ileride
/// GoogleMapsEtaProvider / MapboxEtaProvider aynı arayüzü uygular.
abstract class EtaProvider {
  String get name;
  EtaResult calculate(EtaInput input);
}
