import axios, { AxiosError, type AxiosInstance, type InternalAxiosRequestConfig } from 'axios';
import { env } from '@/config/env';
import { secureStore, STORAGE_KEYS } from '@/lib/secureStore';
import type { AuthTokens } from '@servis/shared';

/** 401 durumunda oturum sonlanınca çağrılan kanca (authStore tarafından set edilir). */
let onSessionExpired: (() => void) | null = null;
export function setOnSessionExpired(cb: () => void): void {
  onSessionExpired = cb;
}

/**
 * Merkezi Axios örneği.
 * - Access token'ı otomatik ekler.
 * - 401'de refresh token ile tek seferlik yenileme dener.
 * - Yenileme başarısızsa oturumu sonlandırır.
 */
export const api: AxiosInstance = axios.create({
  baseURL: env.apiBaseUrl,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  const token = await secureStore.getItem(STORAGE_KEYS.accessToken);
  if (token) config.headers.set('Authorization', `Bearer ${token}`);
  return config;
});

let refreshing: Promise<string | null> | null = null;

async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = await secureStore.getItem(STORAGE_KEYS.refreshToken);
  if (!refreshToken) return null;
  try {
    // Interceptor'suz ham istek — sonsuz döngüyü önler.
    const { data } = await axios.post<AuthTokens>(`${env.apiBaseUrl}/auth/refresh`, {
      refresh_token: refreshToken,
    });
    await secureStore.setItem(STORAGE_KEYS.accessToken, data.access_token);
    await secureStore.setItem(STORAGE_KEYS.refreshToken, data.refresh_token);
    return data.access_token;
  } catch {
    return null;
  }
}

api.interceptors.response.use(
  (res) => res,
  async (error: AxiosError) => {
    const original = error.config as (InternalAxiosRequestConfig & { _retry?: boolean }) | undefined;
    if (error.response?.status === 401 && original && !original._retry) {
      original._retry = true;
      refreshing = refreshing ?? refreshAccessToken();
      const newToken = await refreshing;
      refreshing = null;
      if (newToken) {
        original.headers.set('Authorization', `Bearer ${newToken}`);
        return api(original);
      }
      // Yenileme başarısız → oturumu kapat.
      await secureStore.removeItem(STORAGE_KEYS.accessToken);
      await secureStore.removeItem(STORAGE_KEYS.refreshToken);
      onSessionExpired?.();
    }
    return Promise.reject(normalizeError(error));
  },
);

/** API hatasını kullanıcı dostu, sistem detayı içermeyen biçime indirger. */
export function normalizeError(error: unknown): Error {
  if (axios.isAxiosError(error)) {
    const detail = (error.response?.data as { detail?: string } | undefined)?.detail;
    if (detail) return new Error(detail);
    if (error.code === 'ECONNABORTED') return new Error('İstek zaman aşımına uğradı.');
    if (!error.response) return new Error('Sunucuya ulaşılamıyor.');
    return new Error('İşlem sırasında bir hata oluştu.');
  }
  return error instanceof Error ? error : new Error('Bilinmeyen hata.');
}
