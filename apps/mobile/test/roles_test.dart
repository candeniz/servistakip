import 'package:flutter_test/flutter_test.dart';
import 'package:servis_takip/core/constants/roles.dart';

void main() {
  test('her rol için bir ana ekran rotası tanımlıdır', () {
    for (final role in Role.values) {
      expect(role.homeRoute.isNotEmpty, isTrue);
    }
  });

  test('operations_manager ve company_admin aynı yönetici arayüzünü paylaşır', () {
    expect(Role.operationsManager.homeRoute, Role.companyAdmin.homeRoute);
  });

  test('fromValue geçerli/geçersiz değerleri ayırır', () {
    expect(Role.fromValue('driver'), Role.driver);
    expect(Role.fromValue('super_admin'), Role.superAdmin);
    // Bilinmeyen değer güvenli varsayılana (passenger) düşer.
    expect(Role.fromValue('hacker'), Role.passenger);
  });
}
