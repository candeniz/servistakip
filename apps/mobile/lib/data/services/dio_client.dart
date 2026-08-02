import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import 'token_store.dart';

/// Merkezi Dio örneği oluşturur.
///
/// - Access token'ı otomatik ekler.
/// - 401'de refresh token ile tek seferlik yenileme dener.
/// - Yenileme başarısızsa [onSessionExpired] çağrılır.
class DioClient {
  DioClient({required this.tokenStore, this.onSessionExpired}) {
    dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  final TokenStore tokenStore;
  final void Function()? onSessionExpired;
  late final Dio dio;

  bool _refreshing = false;

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStore.read(TokenKeys.accessToken);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final response = error.response;
    final isUnauthorized = response?.statusCode == 401;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried && !_refreshing) {
      _refreshing = true;
      final newToken = await _refreshAccessToken();
      _refreshing = false;

      if (newToken != null) {
        final req = error.requestOptions;
        req.extra['retried'] = true;
        req.headers['Authorization'] = 'Bearer $newToken';
        try {
          final clone = await dio.fetch<dynamic>(req);
          return handler.resolve(clone);
        } catch (_) {
          // düşerse aşağıdaki normal hata akışına devam
        }
      } else {
        // Yenileme başarısız → oturumu kapat.
        await tokenStore.delete(TokenKeys.accessToken);
        await tokenStore.delete(TokenKeys.refreshToken);
        onSessionExpired?.call();
      }
    }
    handler.next(error);
  }

  Future<String?> _refreshAccessToken() async {
    final refresh = await tokenStore.read(TokenKeys.refreshToken);
    if (refresh == null) return null;
    try {
      // Interceptor'suz ham istemci — sonsuz döngüyü önler.
      final raw = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
      final res = await raw.post<Map<String, dynamic>>('/auth/refresh',
          data: {'refresh_token': refresh});
      final data = res.data!;
      await tokenStore.write(TokenKeys.accessToken, data['access_token'] as String);
      await tokenStore.write(TokenKeys.refreshToken, data['refresh_token'] as String);
      return data['access_token'] as String;
    } catch (_) {
      return null;
    }
  }
}

/// Dio hatasını kullanıcı dostu, sistem detayı içermeyen mesaja indirger.
String normalizeDioError(Object error) {
  if (error is DioException) {
    final detail = (error.response?.data is Map)
        ? (error.response!.data as Map)['detail'] as String?
        : null;
    if (detail != null) return detail;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'İstek zaman aşımına uğradı.';
    }
    if (error.response == null) return 'Sunucuya ulaşılamıyor.';
    return 'İşlem sırasında bir hata oluştu.';
  }
  return 'Bilinmeyen hata.';
}
