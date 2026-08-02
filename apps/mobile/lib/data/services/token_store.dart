import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token depolama arayüzü — testlerde bellek içi, üretimde güvenli depolama.
abstract class TokenStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class TokenKeys {
  const TokenKeys._();
  static const accessToken = 'servis.access_token';
  static const refreshToken = 'servis.refresh_token';
  static const user = 'servis.user';
}

/// Flutter Secure Storage tabanlı güvenli token deposu (üretim).
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Bellek içi token deposu (test/geliştirme).
class InMemoryTokenStore implements TokenStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}
