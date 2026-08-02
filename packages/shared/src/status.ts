/** Ortak durum enum'ları — backend ile paylaşılır, UI etiketleri Türkçedir. */

export const TENANT_STATUS = {
  ACTIVE: 'active',
  SUSPENDED: 'suspended',
  PASSIVE: 'passive',
} as const;
export type TenantStatus = (typeof TENANT_STATUS)[keyof typeof TENANT_STATUS];

export const USER_STATUS = {
  ACTIVE: 'active',
  INVITED: 'invited',
  DISABLED: 'disabled',
} as const;
export type UserStatus = (typeof USER_STATUS)[keyof typeof USER_STATUS];

export const TRIP_STATUS = {
  SCHEDULED: 'scheduled',
  PREPARING: 'preparing',
  ACTIVE: 'active',
  DELAYED: 'delayed',
  PAUSED: 'paused',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const;
export type TripStatus = (typeof TRIP_STATUS)[keyof typeof TRIP_STATUS];

export const TRIP_STATUS_LABELS: Record<TripStatus, string> = {
  scheduled: 'Planlandı',
  preparing: 'Hazırlanıyor',
  active: 'Yolda',
  delayed: 'Gecikmeli',
  paused: 'Duraklatıldı',
  completed: 'Tamamlandı',
  cancelled: 'İptal',
};

export const BOARDING_STATUS = {
  EXPECTED: 'expected',
  BOARDED: 'boarded',
  NO_SHOW: 'no_show',
  ABSENT: 'absent',
  WRONG_STOP: 'wrong_stop',
  CANCELLED: 'cancelled',
} as const;
export type BoardingStatus = (typeof BOARDING_STATUS)[keyof typeof BOARDING_STATUS];

export const BOARDING_STATUS_LABELS: Record<BoardingStatus, string> = {
  expected: 'Bekleniyor',
  boarded: 'Bindi',
  no_show: 'Gelmedi',
  absent: 'İzinli',
  wrong_stop: 'Yanlış Durak',
  cancelled: 'İptal',
};

export const VEHICLE_STATUS = {
  ACTIVE: 'active',
  MAINTENANCE: 'maintenance',
  PASSIVE: 'passive',
} as const;
export type VehicleStatus = (typeof VEHICLE_STATUS)[keyof typeof VEHICLE_STATUS];

export const ROUTE_DIRECTION = {
  MORNING: 'morning',
  EVENING: 'evening',
} as const;
export type RouteDirection = (typeof ROUTE_DIRECTION)[keyof typeof ROUTE_DIRECTION];

export const INCIDENT_TYPE = {
  DELAY: 'delay',
  TRAFFIC: 'traffic',
  BREAKDOWN: 'breakdown',
  ACCIDENT: 'accident',
  OTHER: 'other',
} as const;
export type IncidentType = (typeof INCIDENT_TYPE)[keyof typeof INCIDENT_TYPE];

export const INCIDENT_TYPE_LABELS: Record<IncidentType, string> = {
  delay: 'Gecikme',
  traffic: 'Trafik',
  breakdown: 'Arıza',
  accident: 'Kaza',
  other: 'Diğer',
};

export const NOTIFICATION_TYPE = {
  TRIP_STARTED: 'trip_started',
  FIVE_STOPS_AWAY: 'five_stops_away',
  THREE_STOPS_AWAY: 'three_stops_away',
  TEN_MINUTES_AWAY: 'ten_minutes_away',
  APPROACHING_STOP: 'approaching_stop',
  ARRIVED_STOP: 'arrived_stop',
  DELAYED: 'delayed',
  VEHICLE_CHANGED: 'vehicle_changed',
  DRIVER_CHANGED: 'driver_changed',
  TRIP_CANCELLED: 'trip_cancelled',
  ANNOUNCEMENT: 'announcement',
} as const;
export type NotificationType = (typeof NOTIFICATION_TYPE)[keyof typeof NOTIFICATION_TYPE];
