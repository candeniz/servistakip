import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import '../../core/constants/ws_channels.dart';
import '../../core/utils/geo.dart';

/// Konum okuması (doğruluk dahil).
class LocationSample {
  const LocationSample({
    required this.point,
    required this.speed,
    required this.heading,
    required this.accuracy,
  });
  final LatLngPoint point;
  final double speed;
  final double heading;
  final double accuracy;
}

/// Şoför konum takibi.
/// - Yalnızca aktif servis sırasında çalışır.
/// - Kötü GPS doğruluğunu filtreler.
/// - Android'de foreground service (arka plan konumu) kullanır.
/// - Pil için dengeli doğruluk (medium) ayarı.
class LocationService {
  StreamSubscription<Position>? _sub;

  /// Konum izinlerini ister.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> isLocationEnabled() =>
      kIsWeb ? Future.value(false) : Geolocator.isLocationServiceEnabled();

  /// Ön/arka plan konum akışını başlatır. Her geçerli konumu [onSample]'a iletir.
  Future<void> start(void Function(LocationSample) onSample) async {
    if (kIsWeb) return;
    await stop();
    _sub = Geolocator.getPositionStream(locationSettings: _buildSettings()).listen((pos) {
      final acc = pos.accuracy;
      // Doğruluk çok kötüyse konumu işleme alma.
      if (acc > RealtimeConfig.maxAcceptableAccuracyM) return;
      onSample(LocationSample(
        point: LatLngPoint(pos.latitude, pos.longitude),
        speed: pos.speed < 0 ? 0 : pos.speed,
        heading: pos.heading < 0 ? 0 : pos.heading,
        accuracy: acc,
      ));
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  LocationSettings _buildSettings() {
    const distanceFilter = 15;
    if (!kIsWeb && Platform.isAndroid) {
      // Android foreground service ile arka planda konum paylaşımı.
      return AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceFilter,
        intervalDuration: RealtimeConfig.locationInterval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Servis takibi aktif',
          notificationText: 'Konumunuz servis boyunca paylaşılıyor.',
          enableWakeLock: true,
        ),
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: distanceFilter,
    );
  }
}
