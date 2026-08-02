/// Servis yolculuğu durumları.
enum TripStatus {
  scheduled('scheduled', 'Planlandı'),
  preparing('preparing', 'Hazırlanıyor'),
  active('active', 'Yolda'),
  delayed('delayed', 'Gecikmeli'),
  paused('paused', 'Duraklatıldı'),
  completed('completed', 'Tamamlandı'),
  cancelled('cancelled', 'İptal');

  const TripStatus(this.value, this.label);
  final String value;
  final String label;

  static TripStatus fromValue(String value) =>
      TripStatus.values.firstWhere((s) => s.value == value, orElse: () => TripStatus.scheduled);
}

/// Yolcu biniş durumları.
enum BoardingStatus {
  expected('expected', 'Bekleniyor'),
  boarded('boarded', 'Bindi'),
  noShow('no_show', 'Gelmedi'),
  absent('absent', 'İzinli'),
  wrongStop('wrong_stop', 'Yanlış Durak'),
  cancelled('cancelled', 'İptal');

  const BoardingStatus(this.value, this.label);
  final String value;
  final String label;

  static BoardingStatus fromValue(String value) =>
      BoardingStatus.values.firstWhere((s) => s.value == value, orElse: () => BoardingStatus.expected);
}

/// Tenant (şirket) durumları.
enum TenantStatus {
  active('active', 'Aktif'),
  suspended('suspended', 'Askıda'),
  passive('passive', 'Pasif');

  const TenantStatus(this.value, this.label);
  final String value;
  final String label;

  static TenantStatus fromValue(String value) =>
      TenantStatus.values.firstWhere((s) => s.value == value, orElse: () => TenantStatus.passive);
}

/// Servis yönü.
enum RouteDirection {
  morning('morning', 'Sabah'),
  evening('evening', 'Akşam');

  const RouteDirection(this.value, this.label);
  final String value;
  final String label;

  static RouteDirection fromValue(String value) =>
      RouteDirection.values.firstWhere((d) => d.value == value, orElse: () => RouteDirection.morning);
}

/// Olay türleri.
enum IncidentType {
  delay('delay', 'Gecikme'),
  traffic('traffic', 'Trafik'),
  breakdown('breakdown', 'Arıza'),
  accident('accident', 'Kaza'),
  other('other', 'Diğer');

  const IncidentType(this.value, this.label);
  final String value;
  final String label;
}

/// Bildirim türleri (push senaryoları).
enum NotificationType {
  tripStarted('trip_started'),
  fiveStopsAway('five_stops_away'),
  threeStopsAway('three_stops_away'),
  tenMinutesAway('ten_minutes_away'),
  approachingStop('approaching_stop'),
  arrivedStop('arrived_stop'),
  delayed('delayed'),
  vehicleChanged('vehicle_changed'),
  driverChanged('driver_changed'),
  tripCancelled('trip_cancelled'),
  announcement('announcement');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromValue(String value) =>
      NotificationType.values.firstWhere((n) => n.value == value, orElse: () => NotificationType.announcement);
}
