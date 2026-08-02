import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Arka planda gelen FCM mesajlarını işleyen üst düzey handler.
/// (Firebase gereksinimi: top-level + vm:entry-point.)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM arka plan mesajı: ${message.messageId}');
}

/// Push bildirim altyapısı (Firebase Cloud Messaging).
///
/// Firebase çekirdeği main.dart içinde başlatılır; bu servis mesajlaşma
/// (izin + token + dinleyiciler) katmanını yönetir.
class NotificationService {
  bool _initialized = false;
  String? _token;

  /// Son alınan FCM cihaz token'ı (backend'e kaydedilir).
  String? get token => _token;

  /// Bildirim iznini ister, token alır ve mesaj dinleyicilerini kurar.
  /// Firebase yapılandırılmamışsa güvenli biçimde atlanır.
  Future<void> init() async {
    if (_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      _token = await _fetchToken(messaging);

      // Ön planda gelen bildirimler
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM ön plan: ${message.notification?.title}');
      });

      // Token yenilendiğinde güncelle
      messaging.onTokenRefresh.listen((t) => _token = t);

      _initialized = true;
    } catch (e) {
      // Firebase yoksa / web'de vapid anahtarı yoksa uygulamayı bloklama.
      debugPrint('NotificationService başlatılamadı: $e');
    }
  }

  Future<String?> _fetchToken(FirebaseMessaging messaging) async {
    try {
      // Web'de gerçek token için VAPID anahtarı gerekir; yoksa sessizce atlanır.
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM token alınamadı: $e');
      return null;
    }
  }
}
