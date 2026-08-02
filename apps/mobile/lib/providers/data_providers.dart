import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_notification.dart';
import '../data/models/service_route.dart';
import '../data/models/service_trip.dart';
import '../data/models/tenant.dart';
import '../data/models/vehicle.dart';
import 'core_providers.dart';

final tenantsProvider = FutureProvider<List<Tenant>>((ref) {
  return ref.watch(dataServiceProvider).listTenants();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) {
  return ref.watch(dataServiceProvider).listVehicles();
});

final tripsProvider = FutureProvider<List<ServiceTrip>>((ref) {
  return ref.watch(dataServiceProvider).listTrips();
});

final tripProvider = FutureProvider.family<ServiceTrip, String>((ref, id) {
  return ref.watch(dataServiceProvider).getTrip(id);
});

final tripPassengersProvider = FutureProvider.family<List<TripPassenger>, String>((ref, tripId) {
  return ref.watch(dataServiceProvider).listTripPassengers(tripId);
});

final routeProvider = FutureProvider.family<ServiceRoute, String>((ref, id) {
  return ref.watch(dataServiceProvider).getRoute(id);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(dataServiceProvider).listNotifications();
});
