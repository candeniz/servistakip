import type { EtaResult } from '@servis/shared';
import type { ETAProvider, EtaInput } from './types';

/**
 * Google Maps Directions API tabanlı ETA sağlayıcı (iskelet).
 * API anahtarı ayarlandığında gerçek istekle doldurulur; şu an
 * MockETAProvider ile aynı sözleşmeyi uygular ancak aktif değildir.
 */
export class GoogleMapsETAProvider implements ETAProvider {
  readonly name = 'google';

  constructor(private readonly apiKey: string) {}

  async calculate(_input: EtaInput): Promise<EtaResult> {
    if (!this.apiKey) {
      throw new Error('GoogleMapsETAProvider: API anahtarı tanımlı değil.');
    }
    // TODO(prod): Directions API'ye origin=aracın konumu, waypoints=kalan duraklar,
    // destination=hedef durak ile istek at; duration_in_traffic değerini kullan.
    throw new Error('GoogleMapsETAProvider henüz uygulanmadı — ETA_PROVIDER=mock kullanın.');
  }
}
