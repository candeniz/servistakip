import 'package:flutter_test/flutter_test.dart';
import 'package:servis_takip/data/eta/eta_provider.dart';
import 'package:servis_takip/data/eta/mock_eta_provider.dart';
import 'package:servis_takip/data/mock/demo_data.dart';

void main() {
  final provider = MockEtaProvider();

  test('hedef durak için kalan durak sayısını doğru hesaplar', () {
    final result = provider.calculate(EtaInput(
      vehicleLocation: demoStops.first.point,
      stops: demoStops,
      nextStopIndex: 1,
      targetStopIndex: 4,
      plannedArrivalAt: DateTime.now(),
    ));
    expect(result.remainingStops, 4);
    expect(result.remainingDistanceMeters, greaterThan(0));
    expect(result.etaMinutes, greaterThanOrEqualTo(0));
  });

  test('araç ilerledikçe ETA azalır', () {
    final far = provider.calculate(EtaInput(
      vehicleLocation: demoStops[0].point,
      stops: demoStops,
      nextStopIndex: 1,
      targetStopIndex: 4,
      plannedArrivalAt: DateTime.now(),
    ));
    final near = provider.calculate(EtaInput(
      vehicleLocation: demoStops[3].point,
      stops: demoStops,
      nextStopIndex: 4,
      targetStopIndex: 4,
      plannedArrivalAt: DateTime.now(),
    ));
    expect(near.remainingDistanceMeters, lessThan(far.remainingDistanceMeters));
    expect(near.remainingStops, lessThan(far.remainingStops));
  });
}
