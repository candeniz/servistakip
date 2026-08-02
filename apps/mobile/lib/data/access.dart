import '../core/constants/roles.dart';
import 'models/auth_models.dart';
import 'models/service_trip.dart';

/// İstemci tarafı görünürlük kuralları (UX içindir; asıl kontrol backend'de).
///
/// - Şoför yalnızca kendisine atanmış servisleri görür.
/// - Yolcu yalnızca yolcusu olduğu servisleri görür.
/// - Yönetici/operasyon yalnızca kendi tenant'ının servislerini görür.
/// - Süper admin platform genelini görür.
bool canViewTrip(AuthUser user, ServiceTrip trip, {Set<String> passengerTripIds = const {}}) {
  // Tenant izolasyonu: super_admin hariç farklı tenant görülemez.
  if (user.role != Role.superAdmin && user.tenantId != trip.tenantId) return false;

  switch (user.role) {
    case Role.superAdmin:
      return true;
    case Role.companyAdmin:
    case Role.operationsManager:
      return true; // aynı tenant
    case Role.driver:
      return trip.driverId == user.id;
    case Role.passenger:
      return passengerTripIds.contains(trip.id);
  }
}

/// Kullanıcının bir kayda tenant açısından erişimi.
bool assertSameTenant(AuthUser user, String recordTenantId) =>
    user.role == Role.superAdmin || user.tenantId == recordTenantId;

/// Bir kullanıcı için görünür servisleri süzer.
List<ServiceTrip> scopeTrips(AuthUser user, List<ServiceTrip> trips,
        {Set<String> passengerTripIds = const {}}) =>
    trips.where((t) => canViewTrip(user, t, passengerTripIds: passengerTripIds)).toList();
