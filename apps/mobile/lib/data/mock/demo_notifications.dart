import '../../core/constants/statuses.dart';
import '../models/app_notification.dart';

DateTime _ago(int minutes) => DateTime.now().subtract(Duration(minutes: minutes));

/// Yolcu için örnek bildirimler (senaryo).
final List<AppNotification> demoNotifications = [
  AppNotification(
    id: 'ntf-1',
    title: 'Servis başladı',
    message: 'Avrupa Yakası Sabah Servisi yola çıktı.',
    type: NotificationType.tripStarted,
    readAt: null,
    createdAt: _ago(8),
  ),
  AppNotification(
    id: 'ntf-2',
    title: 'Servis gecikiyor',
    message: 'Trafik nedeniyle yaklaşık 3 dakika gecikme bekleniyor.',
    type: NotificationType.delayed,
    readAt: null,
    createdAt: _ago(5),
  ),
  AppNotification(
    id: 'ntf-3',
    title: 'Servis 5 durak uzakta',
    message: 'Aracınız durağınıza 5 durak uzaklıkta.',
    type: NotificationType.fiveStopsAway,
    readAt: _ago(30),
    createdAt: _ago(30),
  ),
];
