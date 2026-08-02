import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';
import { api } from './apiClient';
import { env } from '@/config/env';

/**
 * Push bildirim altyapısı.
 * - İzin ister, Expo push token alır ve backend'e (DeviceToken) kaydeder.
 * - Mock modda token backend'e gönderilmez.
 */

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

/** Bildirim iznini ister. */
export async function requestNotificationPermissions(): Promise<boolean> {
  if (Platform.OS === 'web') return false;
  const existing = await Notifications.getPermissionsAsync();
  let status = existing.status;
  if (status !== 'granted') {
    const req = await Notifications.requestPermissionsAsync();
    status = req.status;
  }
  return status === 'granted';
}

/** Expo push token alır ve backend'e kaydeder (varsa). */
export async function registerDeviceToken(): Promise<string | null> {
  if (Platform.OS === 'web') return null;
  const granted = await requestNotificationPermissions();
  if (!granted) return null;

  try {
    const { data: token } = await Notifications.getExpoPushTokenAsync();
    if (!env.useMock) {
      await api.post('/notifications/device-tokens', {
        token,
        platform: Platform.OS,
      });
    }
    return token;
  } catch {
    return null;
  }
}
