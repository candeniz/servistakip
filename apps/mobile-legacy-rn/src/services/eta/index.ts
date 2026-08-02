import { MockETAProvider } from './MockETAProvider';
import { GoogleMapsETAProvider } from './GoogleMapsETAProvider';
import { MapboxETAProvider } from './MapboxETAProvider';
import type { ETAProvider } from './types';

export type { ETAProvider, EtaInput } from './types';
export { MockETAProvider, GoogleMapsETAProvider, MapboxETAProvider };

/**
 * Yapılandırmaya göre aktif ETA sağlayıcısını döndürür.
 * MVP varsayılanı: mock.
 */
export function createEtaProvider(
  kind: 'mock' | 'google' | 'mapbox' = 'mock',
  keys: { googleMapsApiKey?: string; mapboxAccessToken?: string } = {},
): ETAProvider {
  switch (kind) {
    case 'google':
      return new GoogleMapsETAProvider(keys.googleMapsApiKey ?? '');
    case 'mapbox':
      return new MapboxETAProvider(keys.mapboxAccessToken ?? '');
    case 'mock':
    default:
      return new MockETAProvider();
  }
}

/** Uygulama genelinde paylaşılan varsayılan sağlayıcı. */
export const etaProvider: ETAProvider = createEtaProvider('mock');
