import '../models/eta_result.dart';
import 'eta_provider.dart';

/// Google Maps Directions API tabanlı ETA sağlayıcı (iskelet).
/// API anahtarı ayarlandığında gerçek istekle doldurulur.
class GoogleMapsEtaProvider implements EtaProvider {
  GoogleMapsEtaProvider(this.apiKey);
  final String apiKey;

  @override
  String get name => 'google';

  @override
  EtaResult calculate(EtaInput input) {
    // TODO(prod): Directions API'ye origin=araç, waypoints=kalan duraklar,
    // destination=hedef durak ile istek at; duration_in_traffic kullan.
    throw UnimplementedError('GoogleMapsEtaProvider henüz uygulanmadı — ETA_PROVIDER=mock kullanın.');
  }
}

/// Mapbox Directions API tabanlı ETA sağlayıcı (iskelet).
class MapboxEtaProvider implements EtaProvider {
  MapboxEtaProvider(this.accessToken);
  final String accessToken;

  @override
  String get name => 'mapbox';

  @override
  EtaResult calculate(EtaInput input) {
    throw UnimplementedError('MapboxEtaProvider henüz uygulanmadı — ETA_PROVIDER=mock kullanın.');
  }
}
