import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/statuses.dart';
import '../core/utils/geo.dart';
import '../data/mock/demo_data.dart';
import '../data/models/service_trip.dart';
import '../data/simulation/simulation_engine.dart';

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

/// Demo yolculuğu için paylaşılan simülasyon controller'ı.
/// Şoför "Servisi Başlat" ile veya yolcu ekranı açılışında başlatır; her iki rol
/// de aynı araç hareketini görür.
class SimulationController extends Notifier<SimulationState> {
  SimulationEngine? _engine;
  StreamSubscription<SimulationTick>? _sub;

  @override
  SimulationState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _engine?.dispose();
    });
    return SimulationState.initial();
  }

  void start() {
    if (state.running) return;
    _engine ??= SimulationEngine(path: demoSimulationPath, stops: demoStops);
    _sub ??= _engine!.stream.listen(_onTick);
    _engine!.start();
    state = state.copyWith(running: true);
  }

  void stop() {
    _engine?.stop();
    state = state.copyWith(running: false);
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

  /// Araç geçtiği duraklardaki bekleyen yolcuları otomatik bindirir.
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
