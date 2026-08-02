import { NOTIFICATION_TYPE, type AppNotification } from '@servis/shared';
import { DEMO_TENANT_ID, DEMO_PASSENGER_ID } from './demoUsers';

function iso(minutesAgo: number): string {
  return new Date(Date.now() - minutesAgo * 60000).toISOString();
}

/** Yolcu için örnek bildirimler (senaryo). */
export const demoNotifications: AppNotification[] = [
  {
    id: 'ntf-1',
    tenant_id: DEMO_TENANT_ID,
    user_id: DEMO_PASSENGER_ID,
    title: 'Servis başladı',
    message: 'Avrupa Yakası Sabah Servisi yola çıktı.',
    type: NOTIFICATION_TYPE.TRIP_STARTED,
    data: null,
    read_at: null,
    created_at: iso(8),
  },
  {
    id: 'ntf-2',
    tenant_id: DEMO_TENANT_ID,
    user_id: DEMO_PASSENGER_ID,
    title: 'Servis gecikiyor',
    message: 'Trafik nedeniyle yaklaşık 3 dakika gecikme bekleniyor.',
    type: NOTIFICATION_TYPE.DELAYED,
    data: { delay_minutes: 3 },
    read_at: null,
    created_at: iso(5),
  },
  {
    id: 'ntf-3',
    tenant_id: DEMO_TENANT_ID,
    user_id: DEMO_PASSENGER_ID,
    title: 'Servis 5 durak uzakta',
    message: 'Aracınız durağınıza 5 durak uzaklıkta.',
    type: NOTIFICATION_TYPE.FIVE_STOPS_AWAY,
    data: null,
    read_at: iso(30),
    created_at: iso(30),
  },
];
