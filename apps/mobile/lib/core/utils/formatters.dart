import 'package:intl/intl.dart';

/// Türkçe biçimlendirme yardımcıları.
class Fmt {
  const Fmt._();

  static final _time = DateFormat.Hm('tr_TR');
  static final _date = DateFormat('dd.MM.yyyy', 'tr_TR');

  static String time(DateTime? dt) => dt == null ? '—' : _time.format(dt.toLocal());

  static String date(DateTime? dt) => dt == null ? '—' : _date.format(dt.toLocal());

  /// Metreyi okunabilir mesafeye çevirir (m / km).
  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String minutes(num m) => '${m.round().clamp(0, 1 << 31)} dk';

  /// "az önce / 5 dk önce / 2 sa önce" göreli zaman.
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final min = diff.inMinutes;
    if (min < 1) return 'az önce';
    if (min < 60) return '$min dk önce';
    final hr = diff.inHours;
    if (hr < 24) return '$hr sa önce';
    return '${diff.inDays} gün önce';
  }
}
