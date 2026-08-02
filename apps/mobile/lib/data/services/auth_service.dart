import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../mock/demo_users.dart';
import '../models/auth_models.dart';

/// Kimlik doğrulama servisi arayüzü — mock ve gerçek uygulamalar bunu paylaşır.
abstract class AuthService {
  Future<LoginResult> login(String email, String password);
  Future<AuthUser> me();
  Future<void> logout();
}

/// Backend olmadan çalışan mock kimlik doğrulama.
class MockAuthService implements AuthService {
  @override
  Future<LoginResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final normalized = email.trim().toLowerCase();
    for (final acc in demoAccounts) {
      if (acc.user.email.toLowerCase() == normalized) {
        if (acc.password != password) throw Exception('E-posta veya şifre hatalı.');
        return LoginResult(
          user: acc.user,
          tokens: AuthTokens(
            accessToken: 'mock-access-${acc.user.id}',
            refreshToken: 'mock-refresh-${acc.user.id}',
            expiresIn: 900,
          ),
        );
      }
    }
    throw Exception('E-posta veya şifre hatalı.');
  }

  @override
  Future<AuthUser> me() async => throw Exception('Mock modda /me oturum durumundan okunur.');

  @override
  Future<void> logout() async => Future<void>.delayed(const Duration(milliseconds: 100));
}

/// Gerçek backend'e bağlanan kimlik doğrulama.
class ApiAuthService implements AuthService {
  ApiAuthService(this._dio);
  final Dio _dio;

  @override
  Future<LoginResult> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>('/auth/login',
        data: {'email': email, 'password': password});
    return LoginResult.fromJson(res.data!);
  }

  @override
  Future<AuthUser> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(res.data!);
  }

  @override
  Future<void> logout() async => _dio.post<void>('/auth/logout');
}

/// Yapılandırmaya göre aktif servis (mock varsayılan).
AuthService createAuthService(Dio dio) =>
    Env.useMock ? MockAuthService() : ApiAuthService(dio);
