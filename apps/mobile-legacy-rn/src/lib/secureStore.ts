import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

/**
 * Token depolama sarmalayıcısı.
 * Native: Expo Secure Store (şifreli). Web: localStorage (yalnız geliştirme).
 */
const memoryFallback = new Map<string, string>();

async function webGet(key: string): Promise<string | null> {
  try {
    return globalThis.localStorage?.getItem(key) ?? memoryFallback.get(key) ?? null;
  } catch {
    return memoryFallback.get(key) ?? null;
  }
}

export const secureStore = {
  async getItem(key: string): Promise<string | null> {
    if (Platform.OS === 'web') return webGet(key);
    return SecureStore.getItemAsync(key);
  },
  async setItem(key: string, value: string): Promise<void> {
    if (Platform.OS === 'web') {
      try {
        globalThis.localStorage?.setItem(key, value);
      } catch {
        memoryFallback.set(key, value);
      }
      return;
    }
    await SecureStore.setItemAsync(key, value);
  },
  async removeItem(key: string): Promise<void> {
    if (Platform.OS === 'web') {
      try {
        globalThis.localStorage?.removeItem(key);
      } catch {
        memoryFallback.delete(key);
      }
      return;
    }
    await SecureStore.deleteItemAsync(key);
  },
};

export const STORAGE_KEYS = {
  accessToken: 'servis.access_token',
  refreshToken: 'servis.refresh_token',
  user: 'servis.user',
} as const;
