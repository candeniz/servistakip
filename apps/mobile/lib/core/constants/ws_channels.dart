/// WebSocket kanal adları ve olay tipleri (backend ile eşleşir).
///
/// İzolasyon kanal seviyesinde: her kullanıcı yalnızca yetkili olduğu kanala
/// bağlanabilir (yetkilendirme backend'de yapılır).
class WsChannels {
  const WsChannels._();

  static String tenantOperations(String tenantId) => 'tenant:$tenantId:operations';
  static String tripLocation(String tripId) => 'trip:$tripId:location';
  static String userNotifications(String userId) => 'user:$userId:notifications';
}

/// WebSocket üzerinden taşınan olay tipleri.
class WsEvents {
  const WsEvents._();

  static const String locationUpdate = 'location_update';
  static const String etaUpdate = 'eta_update';
  static const String tripStatus = 'trip_status';
  static const String stopArrived = 'stop_arrived';
  static const String stopDeparted = 'stop_departed';
  static const String passengerUpdate = 'passenger_update';
  static const String notification = 'notification';
  static const String connectionLost = 'connection_lost';
}

/// Konum paylaşımı ve yeniden bağlanma sabitleri.
class RealtimeConfig {
  const RealtimeConfig._();

  /// Aktif serviste konum gönderme aralığı.
  static const Duration locationInterval = Duration(seconds: 7);

  /// Bu değerden kötü doğrulukta (metre) konumlar işlenmez.
  static const double maxAcceptableAccuracyM = 60;

  /// WebSocket exponential backoff.
  static const Duration reconnectBaseDelay = Duration(seconds: 1);
  static const Duration reconnectMaxDelay = Duration(seconds: 30);
  static const int reconnectFactor = 2;
  static const int reconnectMaxAttempts = 10;

  /// Varsayılan durak yarıçapı (geofence).
  static const int defaultStopRadiusM = 120;
}
