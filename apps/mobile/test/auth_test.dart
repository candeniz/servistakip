import 'package:flutter_test/flutter_test.dart';
import 'package:servis_takip/core/constants/roles.dart';
import 'package:servis_takip/data/services/auth_service.dart';

void main() {
  final service = MockAuthService();

  test('doğru demo bilgileriyle giriş yapılır ve rol atanır', () async {
    final result = await service.login('sofor@demo.com', 'Demo123!');
    expect(result.user.role, Role.driver);
    expect(result.user.email, 'sofor@demo.com');
    expect(result.tokens.accessToken, isNotEmpty);
  });

  test('hatalı şifre girişi reddeder', () {
    expect(() => service.login('yolcu@demo.com', 'yanlis'), throwsException);
  });

  test('tanımsız e-posta reddeder', () {
    expect(() => service.login('yok@demo.com', 'Demo123!'), throwsException);
  });

  test('her rol için demo hesap girişi çalışır', () async {
    final emails = {
      'superadmin@demo.com': Role.superAdmin,
      'yonetici@demo.com': Role.companyAdmin,
      'sofor@demo.com': Role.driver,
      'yolcu@demo.com': Role.passenger,
    };
    for (final entry in emails.entries) {
      final result = await service.login(entry.key, 'Demo123!');
      expect(result.user.role, entry.value);
    }
  });
}
