import { ROLES, type AuthUser, type ServiceTrip } from '@servis/shared';

/**
 * İstemci tarafı görünürlük kuralları (UX içindir; asıl kontrol backend'de).
 * - Şoför yalnızca kendisine atanmış servisleri görür.
 * - Yolcu yalnızca yolcusu olduğu servisleri görür.
 * - Yönetici/operasyon yalnızca kendi tenant'ının servislerini görür.
 * - Süper admin platform genelini görür.
 */
export function canViewTrip(
  user: AuthUser,
  trip: ServiceTrip,
  passengerTripIds: Set<string> = new Set(),
): boolean {
  // Tenant izolasyonu: super_admin hariç farklı tenant görülemez.
  if (user.role !== ROLES.SUPER_ADMIN && user.tenant_id !== trip.tenant_id) {
    return false;
  }
  switch (user.role) {
    case ROLES.SUPER_ADMIN:
      return true;
    case ROLES.COMPANY_ADMIN:
    case ROLES.OPERATIONS_MANAGER:
      return true; // aynı tenant
    case ROLES.DRIVER:
      return trip.driver_id === user.id;
    case ROLES.PASSENGER:
      return passengerTripIds.has(trip.id);
    default:
      return false;
  }
}

/** Kullanıcının bir kayda tenant açısından erişebilir olup olmadığı. */
export function assertSameTenant(user: AuthUser, recordTenantId: string): boolean {
  if (user.role === ROLES.SUPER_ADMIN) return true;
  return user.tenant_id === recordTenantId;
}

/** Bir kullanıcı için görünür servisleri süzer. */
export function scopeTrips(
  user: AuthUser,
  trips: ServiceTrip[],
  passengerTripIds: Set<string> = new Set(),
): ServiceTrip[] {
  return trips.filter((t) => canViewTrip(user, t, passengerTripIds));
}
