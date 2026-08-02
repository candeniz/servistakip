import { Platform } from 'react-native';
import * as Location from 'expo-location';
import * as TaskManager from 'expo-task-manager';
import { LOCATION_CONFIG } from '@servis/shared';
import type { LatLng } from '@servis/shared';

/**
 * Şoför konum takibi.
 * - Yalnızca aktif servis sırasında çalışır.
 * - Kötü GPS doğruluğunu filtreler.
 * - Arka plana geçince Expo Task Manager görevini kullanır.
 * - Pil için dengeli doğruluk (Balanced) ayarı.
 */

export interface PermissionResult {
  foreground: boolean;
  background: boolean;
}

/** Konum izinlerini ister. */
export async function requestLocationPermissions(): Promise<PermissionResult> {
  const fg = await Location.requestForegroundPermissionsAsync();
  let backgroundGranted = false;
  if (fg.status === 'granted' && Platform.OS !== 'web') {
    try {
      const res = await Location.requestBackgroundPermissionsAsync();
      backgroundGranted = res.status === 'granted';
    } catch {
      // Bazı platformlarda arka plan izni istenemez; foreground yeterli.
    }
  }
  return {
    foreground: fg.status === 'granted',
    background: backgroundGranted,
  };
}

/** GPS'in açık olup olmadığını kontrol eder. */
export async function isLocationEnabled(): Promise<boolean> {
  try {
    return await Location.hasServicesEnabledAsync();
  } catch {
    return false;
  }
}

type LocationSink = (point: LatLng & { speed: number; heading: number; accuracy: number }) => void;

// Aktif takip için tekil watcher.
let watcher: Location.LocationSubscription | null = null;

/**
 * Ön planda konum izlemeyi başlatır. Her geçerli konumu `sink`'e iletir.
 * Doğruluğu eşik değerinden kötü olan okumalar atlanır.
 */
export async function startForegroundTracking(sink: LocationSink): Promise<void> {
  if (Platform.OS === 'web') return;
  await stopForegroundTracking();
  watcher = await Location.watchPositionAsync(
    {
      accuracy: Location.Accuracy.Balanced,
      timeInterval: LOCATION_CONFIG.UPDATE_INTERVAL_MS,
      distanceInterval: 15,
    },
    (pos) => {
      const acc = pos.coords.accuracy ?? 999;
      // Doğruluk çok kötüyse konumu işleme alma.
      if (acc > LOCATION_CONFIG.MAX_ACCEPTABLE_ACCURACY_M) return;
      sink({
        latitude: pos.coords.latitude,
        longitude: pos.coords.longitude,
        speed: Math.max(0, pos.coords.speed ?? 0),
        heading: pos.coords.heading ?? 0,
        accuracy: acc,
      });
    },
  );
}

export async function stopForegroundTracking(): Promise<void> {
  watcher?.remove();
  watcher = null;
}

/** Arka plan konum görevini (kayıtlıysa) durdurur. */
export async function stopBackgroundTracking(): Promise<void> {
  if (Platform.OS === 'web') return;
  try {
    const registered = await TaskManager.isTaskRegisteredAsync(LOCATION_CONFIG.BACKGROUND_TASK);
    if (registered) {
      await Location.stopLocationUpdatesAsync(LOCATION_CONFIG.BACKGROUND_TASK);
    }
  } catch {
    // Görev yoksa sessiz geç.
  }
}

// Arka plan görevi tanımı — modül yüklenirken bir kez kaydedilir.
// Gerçek gönderim (WS/api) prod'da burada yapılır; şu an güvenli biçimde no-op.
if (Platform.OS !== 'web') {
  TaskManager.defineTask(LOCATION_CONFIG.BACKGROUND_TASK, async ({ data, error }) => {
    if (error || !data) return;
    // TODO(prod): data.locations değerlerini doğruluk filtresinden geçirip WS ile gönder.
  });
}
