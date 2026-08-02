import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servis_takip/data/mock/demo_data.dart';
import 'package:servis_takip/data/simulation/simulation_engine.dart';

void main() {
  test('başlangıçta ilk konumu yayınlar', () {
    final engine = SimulationEngine(path: demoSimulationPath, stops: demoStops);
    final tick = engine.current;
    expect(tick.location, isNotNull);
    engine.dispose();
  });

  test('adım ilerledikçe araç konumu değişir', () {
    fakeAsync((async) {
      final engine = SimulationEngine(
        path: demoSimulationPath,
        stops: demoStops,
        interval: const Duration(seconds: 1),
      );
      final first = engine.current.location;
      engine.start();
      async.elapse(const Duration(seconds: 3));
      final later = engine.current.location;
      expect(later.latitude == first.latitude && later.longitude == first.longitude, isFalse);
      engine.dispose();
    });
  });

  test('yol sonunda finished=true olur', () {
    fakeAsync((async) {
      final shortPath = demoSimulationPath.sublist(0, 3);
      final engine = SimulationEngine(
        path: shortPath,
        stops: demoStops,
        interval: const Duration(milliseconds: 500),
      );
      var finished = false;
      engine.stream.listen((tick) => finished = tick.finished);
      engine.start();
      async.elapse(const Duration(seconds: 5));
      expect(finished, isTrue);
      engine.dispose();
    });
  });
}
