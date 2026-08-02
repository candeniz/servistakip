import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/eta/eta_provider.dart';
import '../data/mock/demo_data.dart';
import '../data/models/eta_result.dart';
import 'core_providers.dart';
import 'simulation_provider.dart';

/// Planlanan varış zamanı — bir kez hesaplanır ve sabit kalır; böylece senaryoya
/// uygun (~3 dk) gecikme çıkar, araç ilerledikçe gecikme azalır.
final passengerPlannedArrivalProvider = Provider<DateTime>((ref) {
  return DateTime.now().add(
    const Duration(minutes: PassengerSnapshot.etaMinutes - PassengerSnapshot.delayMinutes),
  );
});

/// Yolcunun hedef durağı için canlı ETA — simülasyon konumundan hesaplanır.
final passengerEtaProvider = Provider<EtaResult?>((ref) {
  final sim = ref.watch(simulationControllerProvider);
  final location = sim.location;
  if (location == null) return null;

  final provider = ref.watch(etaProviderProvider);
  return provider.calculate(EtaInput(
    vehicleLocation: location,
    stops: demoStops,
    nextStopIndex: sim.nextStopIndex,
    targetStopIndex: passengerStopIndex,
    plannedArrivalAt: ref.watch(passengerPlannedArrivalProvider),
  ));
});
