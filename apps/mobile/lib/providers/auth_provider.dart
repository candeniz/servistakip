import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/auth_models.dart';
import '../data/services/token_store.dart';
import 'core_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.loading = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final bool loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    Object? error = _sentinel,
    bool? loading,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error == _sentinel ? this.error : error as String?,
        loading: loading ?? this.loading,
      );

  static const _sentinel = Object();

  static const initial = AuthState(status: AuthStatus.unknown);
}

/// Oturum durumunu yöneten controller.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 401 sonrası oturum sonlandırma sinyalini dinle.
    ref.listen(sessionExpiredProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        logout();
      }
    });
    // Açılışta saklı oturumu geri yükle.
    Future.microtask(hydrate);
    return AuthState.initial;
  }

  TokenStore get _store => ref.read(tokenStoreProvider);

  Future<void> hydrate() async {
    final token = await _store.read(TokenKeys.accessToken);
    final rawUser = await _store.read(TokenKeys.user);
    if (token != null && rawUser != null) {
      try {
        final user = AuthUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return;
      } catch (_) {
        // bozuk kayıt → temizle
      }
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await ref.read(authServiceProvider).login(email, password);
      await _store.write(TokenKeys.accessToken, result.tokens.accessToken);
      await _store.write(TokenKeys.refreshToken, result.tokens.refreshToken);
      await _store.write(TokenKeys.user, jsonEncode(result.user.toJson()));
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _message(e),
        loading: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
    } catch (_) {
      // sunucu hatası olsa da yerel oturumu temizle
    }
    await _store.delete(TokenKeys.accessToken);
    await _store.delete(TokenKeys.refreshToken);
    await _store.delete(TokenKeys.user);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() => state = state.copyWith(error: null);

  String _message(Object e) {
    final text = e.toString();
    return text.startsWith('Exception: ') ? text.substring('Exception: '.length) : text;
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
