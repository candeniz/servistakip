/** Mobil ve backend arasında paylaşılan sabitler. */

/** WebSocket kanal adları — tenant/trip/user izolasyonu kanal seviyesinde. */
export const WS_CHANNELS = {
  tenantOperations: (tenantId: string) => `tenant:${tenantId}:operations`,
  tripLocation: (tripId: string) => `trip:${tripId}:location`,
  userNotifications: (userId: string) => `user:${userId}:notifications`,
} as const;

/** WebSocket üzerinden taşınan mesaj tipleri. */
export const WS_EVENTS = {
  LOCATION_UPDATE: 'location_update',
  ETA_UPDATE: 'eta_update',
  TRIP_STATUS: 'trip_status',
  STOP_ARRIVED: 'stop_arrived',
  STOP_DEPARTED: 'stop_departed',
  PASSENGER_UPDATE: 'passenger_update',
  NOTIFICATION: 'notification',
  CONNECTION_LOST: 'connection_lost',
} as const;
export type WsEvent = (typeof WS_EVENTS)[keyof typeof WS_EVENTS];

/** Konum paylaşım parametreleri. */
export const LOCATION_CONFIG = {
  /** Aktif serviste konum gönderme aralığı (ms). */
  UPDATE_INTERVAL_MS: 7000,
  /** Bu değerden kötü doğrulukta (metre) konumlar işlenmez. */
  MAX_ACCEPTABLE_ACCURACY_M: 60,
  /** Bu süre boyunca konum gelmezse "bağlantı kesildi" sayılır (ms). */
  STALE_THRESHOLD_MS: 30000,
  /** Arka plan görevi kimliği. */
  BACKGROUND_TASK: 'servis-location-tracking',
} as const;

/** Geofence / durak otomasyonu için varsayılan yarıçap (metre). */
export const DEFAULT_STOP_RADIUS_M = 120;

/** WebSocket yeniden bağlanma (exponential backoff) ayarları. */
export const WS_RECONNECT = {
  BASE_DELAY_MS: 1000,
  MAX_DELAY_MS: 30000,
  FACTOR: 2,
  MAX_ATTEMPTS: 10,
} as const;
