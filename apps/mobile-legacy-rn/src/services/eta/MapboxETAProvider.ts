import type { EtaResult } from '@servis/shared';
import type { ETAProvider, EtaInput } from './types';

/**
 * Mapbox Directions API tabanlı ETA sağlayıcı (iskelet).
 * Access token ayarlandığında gerçek istekle doldurulur.
 */
export class MapboxETAProvider implements ETAProvider {
  readonly name = 'mapbox';

  constructor(private readonly accessToken: string) {}

  async calculate(_input: EtaInput): Promise<EtaResult> {
    if (!this.accessToken) {
      throw new Error('MapboxETAProvider: access token tanımlı değil.');
    }
    // TODO(prod): Mapbox Directions /driving-traffic profiline istek at.
    throw new Error('MapboxETAProvider henüz uygulanmadı — ETA_PROVIDER=mock kullanın.');
  }
}
