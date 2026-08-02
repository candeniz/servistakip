import '../../core/utils/geo.dart';
import '../models/eta_result.dart';
import 'eta_provider.dart';

/// Harici API'ye bağımlı olmayan basit ETA hesaplayıcı.
///
/// Kalan mesafeyi durak zinciri üzerinden toplar, ortalama hız ve durak duruş
/// sürelerini ekleyerek tahmini varış süresini üretir.
class MockEtaProvider implements EtaProvider {
  @override
  String get name => 'mock';

  @override
  EtaResult calculate(EtaInput input) {
    final now = input.now ?? DateTime.now();
    final target = input.targetStopIndex
        .clamp(input.nextStopIndex, input.stops.length - 1);

    // 1) Kalan mesafe: araç -> sıradaki durak -> ... -> hedef durak
    var distance = 0.0;
    if (input.nextStopIndex <= target) {
      distance += haversineMeters(input.vehicleLocation, input.stops[input.nextStopIndex].point);
      for (var i = input.nextStopIndex; i < target; i++) {
        distance += haversineMeters(input.stops[i].point, input.stops[i + 1].point);
      }
    }

    final remainingStops = (target - input.nextStopIndex + 1).clamp(0, input.stops.length);

    // 2) Sürüş süresi (saniye)
    final speedMs = (input.averageSpeedKmh * 1000 / 3600).clamp(1, double.infinity);
    final driveSeconds = distance / speedMs;

    // 3) Ara duraklardaki duruş süreleri (hedef durak hariç)
    final dwellSeconds = ((remainingStops - 1).clamp(0, 1 << 31)) * input.dwellSecondsPerStop;

    final etaSeconds = driveSeconds + dwellSeconds;
    final etaMinutes = (etaSeconds / 60).round().clamp(0, 1 << 31);

    final estimated = now.add(Duration(seconds: etaSeconds.round()));
    final delayMinutes =
        (estimated.difference(input.plannedArrivalAt).inSeconds / 60).round().clamp(0, 1 << 31);

    return EtaResult(
      remainingStops: remainingStops,
      remainingDistanceMeters: distance.roundToDouble(),
      etaMinutes: etaMinutes,
      plannedArrivalAt: input.plannedArrivalAt,
      estimatedArrivalAt: estimated,
      delayMinutes: delayMinutes,
    );
  }
}
