import 'package:flutter_test/flutter_test.dart';
import 'package:servis_takip/core/constants/roles.dart';
import 'package:servis_takip/data/access.dart';
import 'package:servis_takip/data/mock/demo_data.dart';
import 'package:servis_takip/data/models/auth_models.dart';
import 'package:servis_takip/data/models/service_trip.dart';

AuthUser _user(Role role, String id, String? tenantId) => AuthUser(
      id: id,
      tenantId: tenantId,
      firstName: 'Test',
      lastName: 'User',
      email: '$id@demo.com',
      phone: null,
      role: role,
      status: 'active',
      profilePhoto: null,
      tenantName: null,
    );

ServiceTrip _otherTenantTrip() => ServiceTrip(
      id: 'trip-other',
      tenantId: 'tenant-other',
      serviceName: demoTrip.serviceName,
      serviceDate: demoTrip.serviceDate,
      direction: demoTrip.direction,
      routeId: demoTrip.routeId,
      routeName: demoTrip.routeName,
      driverId: demoTrip.driverId,
      driverName: demoTrip.driverName,
      vehicleId: demoTrip.vehicleId,
      vehiclePlate: demoTrip.vehiclePlate,
      plannedStartAt: demoTrip.plannedStartAt,
      actualStartAt: demoTrip.actualStartAt,
      plannedEndAt: demoTrip.plannedEndAt,
      nextStopId: demoTrip.nextStopId,
      status: demoTrip.status,
      delayMinutes: demoTrip.delayMinutes,
      totalDistance: demoTrip.totalDistance,
      passengerCount: demoTrip.passengerCount,
      stopCount: demoTrip.stopCount,
    );

void main() {
  test('şoför yalnızca kendisine atanmış servisi görebilir', () {
    final assigned = _user(Role.driver, demoTrip.driverId, demoTrip.tenantId);
    final other = _user(Role.driver, 'driver-x', demoTrip.tenantId);
    expect(canViewTrip(assigned, demoTrip), isTrue);
    expect(canViewTrip(other, demoTrip), isFalse);
  });

  test('yolcu yalnızca kendi servisini görebilir', () {
    final passenger = _user(Role.passenger, 'user-passenger', demoTrip.tenantId);
    expect(canViewTrip(passenger, demoTrip, passengerTripIds: {demoTrip.id}), isTrue);
    expect(canViewTrip(passenger, demoTrip, passengerTripIds: const {}), isFalse);
  });

  test('tenant izolasyonu: yönetici başka şirketin servisini göremez', () {
    final admin = _user(Role.companyAdmin, 'admin-1', demoTrip.tenantId);
    expect(canViewTrip(admin, demoTrip), isTrue);
    expect(canViewTrip(admin, _otherTenantTrip()), isFalse);
    expect(assertSameTenant(admin, 'tenant-other'), isFalse);
  });

  test('süper admin tüm tenantları görebilir', () {
    final su = _user(Role.superAdmin, 'su-1', null);
    expect(canViewTrip(su, demoTrip), isTrue);
    expect(canViewTrip(su, _otherTenantTrip()), isTrue);
  });

  test('scopeTrips rol ve tenant kurallarını uygular', () {
    final admin = _user(Role.companyAdmin, 'admin-1', demoTrip.tenantId);
    final scoped = scopeTrips(admin, [demoTrip, _otherTenantTrip()]);
    expect(scoped.length, 1);
    expect(scoped.first.id, demoTrip.id);
  });
}
