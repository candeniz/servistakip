import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import '../core/constants/statuses.dart';
import '../core/constants/ws_channels.dart';
import '../core/utils/geo.dart';
import '../data/mock/demo_data.dart';
import '../data/models/service_trip.dart';
import '../data/models/vehicle_location.dart';
import '../data/services/token_store.dart';
import '../data/services/ws_client.dart';
import '../data/simulation/simulation_engine.dart';
import 'core_providers.dart';

class SimulationState {
  const SimulationState({
    required this.running,
    required this.location,
    required this.heading,
    required this.speedKmh,
    required this.nextStopIndex,
    required this.atStopIndex,
    required this.finished,
    required this.passengers,
  });

  final bool running;
  final LatLngPoint? location;
  final double heading;
  final double speedKmh;
  final int nextStopIndex;
  final int? atStopIndex;
  final bool finished;
  final List<TripPassenger> passengers;

  SimulationState copyWith({
    bool? running,
    LatLngPoint? location,
    double? heading,
    double? speedKmh,
    int? nextStopIndex,
    int? atStopIndex,
    bool? finished,
    List<TripPassenger>? passengers,
  }) =>
      SimulationState(
        running: running ?? this.running,
        location: location ?? this.location,
        heading: heading ?? this.heading,
        speedKmh: speedKmh ?? this.speedKmh,
        nextStopIndex: nextStopIndex ?? this.nextStopIndex,
        atStopIndex: atStopIndex,
        finished: finished ?? this.finished,
        passengers: passengers ?? this.passengers,
      );

  static SimulationState initial() => SimulationState(
        running: false,
        location: null,
        heading: 0,
        speedKmh: 0,
        nextStopIndex: 1,
        atStopIndex: null,
        finished: false,
        passengers: List<TripPassenger>.from(demoTripPassengers),
      );
}

/// Canlı yolculuk kaynağı:
/// - Mock mod: [SimulationEngine] araç hareketini üretir.
/// - Gerçek mod: WebSocket `trip:{id}:location` kanalından canlı konum gelir.
/// Ekranlar aynı [SimulationState]'i okur; kaynak şeffaf biçimde değişir.
class SimulationController extends Notifier<SimulationState> {
  SimulationEngine? _engine;
  StreamSubscription<SimulationTick>? _sub;
  WsClient? _ws;
  StreamSubscription<WsMessage>? _wsSub;

  @override
  SimulationState build() {
    ref.onDispose(_teardown);
    return SimulationState.initial();
  }

  void start() {
    if (state.running) return;
    state = state.copyWith(running: true);
    if (Env.useMock) {
      _startSimulation();
    } else {
      _startRealtime();
    }
  }

  void stop() {
    _engine?.stop();
    _wsSub?.cancel();
    _wsSub = null;
    _ws?.close();
    _ws = null;
    state = state.copyWith(running: false);
  }

  void _teardown() {
    _sub?.cancel();
    _engine?.dispose();
    _wsSub?.cancel();
    _ws?.close();
  }

  // ── Mock: simülasyon motoru ──
  void _startSimulation() {
    _engine ??= SimulationEngine(path: demoSimulationPath, stops: demoStops);
    _sub ??= _engine!.stream.listen(_onTick);
    _engine!.start();
  }

  void _onTick(SimulationTick tick) {
    state = SimulationState(
      running: state.running,
      location: tick.location,
      heading: tick.heading,
      speedKmh: tick.speedKmh,
      nextStopIndex: tick.nextStopIndex,
      atStopIndex: tick.atStopIndex,
      finished: tick.finished,
      passengers: _autoBoard(state.passengers, tick.nextStopIndex),
    );
  }

  // ── Gerçek: WebSocket canlı konum ──
  Future<void> _startRealtime() async {
    final token = await ref.read(tokenStoreProvider).read(TokenKeys.accessToken) ?? '';

    // Başlangıçta son bilinen konumu çek.
    try {
      final latest = await ref.read(dataServiceProvider).getLatestLocation(demoTrip.id);
      if (latest != null) _applyRealLocation(latest);
    } catch (_) {
      // Sunucu erişilemezse sessiz geç.
    }

    _ws = WsClient(channel: WsChannels.tripLocation(demoTrip.id), token: token);
    _wsSub = _ws!.messages.listen((msg) {
      if (msg.event == WsEvents.locationUpdate) {
        _applyRealLocation(VehicleLocationDto.fromJson(msg.payload));
      }
    });
    _ws!.connect();
  }

  void _applyRealLocation(VehicleLocationDto loc) {
    final next = _nextStopIndexFor(loc.point);
    state = state.copyWith(
      location: loc.point,
      heading: loc.heading,
      speedKmh: loc.speedKmh,
      nextStopIndex: next,
      passengers: _autoBoard(state.passengers, next),
    );
  }

  /// Gerçek konumdan sıradaki durak index'ini kestirir (en yakın ileri durak).
  int _nextStopIndexFor(LatLngPoint loc) {
    var closest = 0;
    var best = double.infinity;
    for (var i = 0; i < demoStops.length; i++) {
      final d = haversineMeters(loc, demoStops[i].point);
      if (d < best) {
        best = d;
        closest = i;
      }
    }
    if (best <= demoStops[closest].radiusMeters && closest < demoStops.length - 1) {
      return closest + 1;
    }
    return closest;
  }

  List<TripPassenger> _autoBoard(List<TripPassenger> passengers, int nextStopIndex) {
    final stopIndexById = {for (var i = 0; i < demoStops.length; i++) demoStops[i].id: i};
    return passengers.map((p) {
      final idx = stopIndexById[p.stopId] ?? 0;
      if (idx < nextStopIndex && p.boardingStatus == BoardingStatus.expected) {
        return p.copyWith(boardingStatus: BoardingStatus.boarded, boardedAt: DateTime.now());
      }
      return p;
    }).toList();
  }

  void setPassengerStatus(String tripPassengerId, BoardingStatus status) {
    state = state.copyWith(
      passengers: state.passengers.map((p) {
        if (p.id != tripPassengerId) return p;
        return p.copyWith(
          boardingStatus: status,
          boardedAt: status == BoardingStatus.boarded ? DateTime.now() : p.boardedAt,
        );
      }).toList(),
    );
  }
}

final simulationControllerProvider =
    NotifierProvider<SimulationController, SimulationState>(SimulationController.new);
