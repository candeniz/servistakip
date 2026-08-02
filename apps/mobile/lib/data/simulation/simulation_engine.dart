import 'dart:async';

import '../../core/utils/geo.dart';
import '../mock/demo_data.dart';
import '../models/stop.dart';

/// Simülasyon anlık durumu.
class SimulationTick {
  const SimulationTick({
    required this.location,
    required this.heading,
    required this.speedKmh,
    required this.nextStopIndex,
    required this.atStopIndex,
    required this.finished,
  });

  final LatLngPoint location;
  final double heading;
  final double speedKmh;
  final int nextStopIndex;
  final int? atStopIndex;
  final bool finished;
}

/// Backend olmadan aracın harita üzerinde hareketini simüle eder.
/// Konumu günceller, geçilen durakları tespit eder ve dinleyicilere yayınlar.
/// WebSocket geldiğinde bu motor gerçek konum akışıyla değiştirilir.
class SimulationEngine {
  SimulationEngine({
    required this.path,
    required this.stops,
    this.interval = const Duration(seconds: 2),
    this.baseSpeedKmh = 34,
    int startIndex = 0,
  }) : _index = startIndex;

  final List<LatLngPoint> path;
  final List<Stop> stops;
  final Duration interval;
  final double baseSpeedKmh;

  int _index;
  Timer? _timer;
  final _controller = StreamController<SimulationTick>.broadcast();

  Stream<SimulationTick> get stream => _controller.stream;
  bool get isRunning => _timer != null;

  /// Mevcut anlık durum.
  SimulationTick get current => _buildTick();

  void start() {
    if (_timer != null) return;
    _emit(_buildTick());
    _timer = Timer.periodic(interval, (_) => _step());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _step() {
    if (_index >= path.length - 1) {
      stop();
      _emit(_buildTick(finished: true));
      return;
    }
    _index++;
    _emit(_buildTick());
  }

  LatLngPoint get _location => path[_index.clamp(0, path.length - 1)];

  int _computeNextStopIndex() {
    for (var i = 0; i < stops.length; i++) {
      if (!_hasPassedStop(i)) return i;
      if (isWithinRadius(_location, stops[i].point, stops[i].radiusMeters.toDouble())) return i;
    }
    return stops.length - 1;
  }

  bool _hasPassedStop(int stopIndex) => _index > stopIndex * simulationSegmentsPerStop;

  int? _atStop() {
    for (var i = 0; i < stops.length; i++) {
      if (isWithinRadius(_location, stops[i].point, stops[i].radiusMeters.toDouble())) return i;
    }
    return null;
  }

  SimulationTick _buildTick({bool finished = false}) {
    final loc = _location;
    final prev = path[(_index - 1).clamp(0, path.length - 1)];
    final moving = haversineMeters(prev, loc) > 1;
    return SimulationTick(
      location: loc,
      heading: bearingDeg(prev, loc),
      speedKmh: moving ? baseSpeedKmh : 0,
      nextStopIndex: _computeNextStopIndex(),
      atStopIndex: _atStop(),
      finished: finished || _index >= path.length - 1,
    );
  }

  void _emit(SimulationTick tick) {
    if (!_controller.isClosed) _controller.add(tick);
  }
}
