import 'package:flutter/foundation.dart';

import '../../core/config/env.dart';

/// Push bildirim altyapısı (Firebase Cloud Messaging).
///
/// NOT: Firebase kullanımı için `flutterfire configure` ile üretilen yapılandırma
/// (google-services.json / GoogleService-Info.plist) gereklidir. Yapılandırma yoksa
/// başlatma en iyi çaba (best-effort) biçimde atlanır; uygulama çökmeden çalışır.
class NotificationService {
  bool _initialized = false;

  /// Firebase'i başlatır ve bildirim iznini ister. Yapılandırma yoksa sessiz geçer.
  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      // Firebase yapılandırması mevcutsa burada başlatılır:
      //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      //   final messaging = FirebaseMessaging.instance;
      //   await messaging.requestPermission();
      //   final token = await messaging.getToken();
      //   if (!Env.useMock) await _registerDeviceToken(token);
      _initialized = true;
    } catch (e) {
      // Yapılandırma yoksa bildirimleri devre dışı bırak, uygulamayı bloklama.
      debugPrint('NotificationService: Firebase başlatılamadı ($e). Bildirimler pasif.');
    }
  }

  /// Expo/Firebase token'ını backend'e kaydeder (gerçek modda).
  Future<void> registerDeviceToken(String token, String platform) async {
    if (Env.useMock) return;
    // TODO(prod): DioClient üzerinden POST /notifications/device-tokens
  }
}
