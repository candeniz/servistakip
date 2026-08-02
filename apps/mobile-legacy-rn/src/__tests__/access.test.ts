import { canViewTrip, assertSameTenant, scopeTrips } from '@/lib/access';
import { ROLES, type AuthUser, type ServiceTrip } from '@servis/shared';
import { demoTrip } from '@/mocks/demoData';

function makeUser(role: AuthUser['role'], id: string, tenantId: string | null): AuthUser {
  return {
    id,
    tenant_id: tenantId,
    first_name: 'Test',
    last_name: 'User',
    email: `${id}@demo.com`,
    phone: null,
    role,
    status: 'active',
    profile_photo: null,
    tenant_name: null,
  };
}

const otherTenantTrip: ServiceTrip = { ...demoTrip, id: 'trip-other', tenant_id: 'tenant-other' };

describe('erişim kuralları', () => {
  it('şoför yalnızca kendisine atanmış servisi görebilir', () => {
    const assignedDriver = makeUser(ROLES.DRIVER, demoTrip.driver_id, demoTrip.tenant_id);
    const otherDriver = makeUser(ROLES.DRIVER, 'driver-x', demoTrip.tenant_id);
    expect(canViewTrip(assignedDriver, demoTrip)).toBe(true);
    expect(canViewTrip(otherDriver, demoTrip)).toBe(false);
  });

  it('yolcu yalnızca kendi servisini görebilir', () => {
    const passenger = makeUser(ROLES.PASSENGER, 'user-passenger', demoTrip.tenant_id);
    const own = new Set([demoTrip.id]);
    expect(canViewTrip(passenger, demoTrip, own)).toBe(true);
    expect(canViewTrip(passenger, demoTrip, new Set())).toBe(false);
  });

  it('tenant izolasyonu: yönetici başka şirketin servisini göremez', () => {
    const admin = makeUser(ROLES.COMPANY_ADMIN, 'admin-1', demoTrip.tenant_id);
    expect(canViewTrip(admin, demoTrip)).toBe(true);
    expect(canViewTrip(admin, otherTenantTrip)).toBe(false);
    expect(assertSameTenant(admin, otherTenantTrip.tenant_id)).toBe(false);
  });

  it('süper admin tüm tenantları görebilir', () => {
    const su = makeUser(ROLES.SUPER_ADMIN, 'su-1', null);
    expect(canViewTrip(su, demoTrip)).toBe(true);
    expect(canViewTrip(su, otherTenantTrip)).toBe(true);
  });

  it('scopeTrips rol ve tenant kurallarını uygular', () => {
    const admin = makeUser(ROLES.COMPANY_ADMIN, 'admin-1', demoTrip.tenant_id);
    const scoped = scopeTrips(admin, [demoTrip, otherTenantTrip]);
    expect(scoped).toHaveLength(1);
    expect(scoped[0]!.id).toBe(demoTrip.id);
  });
});
