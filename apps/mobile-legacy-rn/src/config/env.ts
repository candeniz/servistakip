import Constants from 'expo-constants';

/**
 * Ortam yapılandırması. Öncelik sırası:
 *  1) EXPO_PUBLIC_* ortam değişkenleri
 *  2) app.json > expo.extra
 *  3) güvenli varsayılanlar
 */
type Extra = {
  apiBaseUrl?: string;
  wsBaseUrl?: string;
  useMock?: boolean;
};

const extra = (Constants.expoConfig?.extra ?? {}) as Extra;

function bool(value: string | undefined, fallback: boolean): boolean {
  if (value === undefined) return fallback;
  return value === 'true' || value === '1';
}

export const env = {
  apiBaseUrl: process.env.EXPO_PUBLIC_API_URL ?? extra.apiBaseUrl ?? 'http://localhost:8000',
  wsBaseUrl: process.env.EXPO_PUBLIC_WS_URL ?? extra.wsBaseUrl ?? 'ws://localhost:8000',
  /** true ise ağ katmanı yerine mock servisler kullanılır (backend olmadan çalışır). */
  useMock: bool(process.env.EXPO_PUBLIC_USE_MOCK, extra.useMock ?? true),
} as const;

export type Env = typeof env;
