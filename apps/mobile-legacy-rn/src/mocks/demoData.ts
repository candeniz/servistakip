import {
  ROUTE_DIRECTION,
  TRIP_STATUS,
  BOARDING_STATUS,
  DEFAULT_STOP_RADIUS_M,
} from '@servis/shared';
import type {
  Tenant,
  Vehicle,
  Stop,
  RouteDetail,
  ServiceTrip,
  TripPassenger,
  LatLng,
} from '@servis/shared';
import { DEMO_TENANT_ID, DEMO_DRIVER_ID, DEMO_PASSENGER_ID } from './demoUsers';

/** ── Tenant ───────────────────────────────────────────── */
export const demoTenant: Tenant = {
  id: DEMO_TENANT_ID,
  name: 'Atlas Teknoloji',
  company_code: 'ATLAS01',
  logo_url: null,
  primary_color: '#1E5EFF',
  status: 'active',
  package_id: 'pkg-pro',
  user_limit: 250,
  vehicle_limit: 20,
  active_user_count: 143,
  active_trip_count: 6,
  created_at: '2025-01-10T08:00:00Z',
  updated_at: '2026-07-30T08:00:00Z',
};

/** Platform genelinde super-admin dashboard için ek örnek şirketler. */
export const demoTenants: Tenant[] = [
  demoTenant,
  {
    ...demoTenant,
    id: 'tenant-nova',
    name: 'Nova Lojistik',
    company_code: 'NOVA02',
    primary_color: '#1DAA6D',
    active_user_count: 88,
    active_trip_count: 3,
    user_limit: 120,
    vehicle_limit: 12,
  },
  {
    ...demoTenant,
    id: 'tenant-delta',
    name: 'Delta Üretim',
    company_code: 'DELTA03',
    status: 'suspended',
    primary_color: '#F2A007',
    active_user_count: 0,
    active_trip_count: 0,
    user_limit: 60,
    vehicle_limit: 6,
  },
];

/** ── Araç ─────────────────────────────────────────────── */
export const demoVehicle: Vehicle = {
  id: 'vehicle-34st2026',
  tenant_id: DEMO_TENANT_ID,
  plate_number: '34 ST 2026',
  brand: 'Mercedes-Benz',
  model: 'Sprinter',
  year: 2023,
  capacity: 19,
  vehicle_type: 'minibus',
  inspection_expiry_date: '2027-03-01',
  insurance_expiry_date: '2026-11-15',
  status: 'active',
};

export const demoVehicles: Vehicle[] = [
  demoVehicle,
  {
    ...demoVehicle,
    id: 'vehicle-34xy1400',
    plate_number: '34 XY 1400',
    brand: 'Ford',
    model: 'Transit',
    capacity: 16,
  },
];

/**
 * ── Duraklar (8 adet) ─────────────────────────────────────
 * Avrupa Yakası (Beylikdüzü çevresi) sabah güzergâhı.
 * order_index sırasına göre araç ilerler.
 */
export const demoStops: Stop[] = [
  ['stop-1', 'Esenyurt Merkez', 41.0341, 28.68, 0],
  ['stop-2', 'Haramidere', 41.02, 28.662, 6],
  ['stop-3', 'Beylikdüzü Cumhuriyet', 41.007, 28.646, 12],
  ['stop-4', 'Gürpınar Sahil', 40.997, 28.636, 18],
  ['stop-5', 'Beylikdüzü Meydan', 41.003, 28.641, 24], // Yolcunun durağı
  ['stop-6', 'Yakuplu', 41.012, 28.657, 30],
  ['stop-7', 'Beylikdüzü E-5', 41.026, 28.671, 36],
  ['stop-8', 'Atlas Plaza (Varış)', 41.045, 28.702, 45],
].map(([id, name, lat, lng, offset], i) => ({
  id: id as string,
  tenant_id: DEMO_TENANT_ID,
  route_id: 'route-avrupa-sabah',
  name: name as string,
  latitude: lat as number,
  longitude: lng as number,
  order_index: i,
  planned_arrival_offset: offset as number,
  radius_meters: DEFAULT_STOP_RADIUS_M,
  status: 'active',
}));

/** Yolcunun (Zeynep) durağı ve ona kalan durak sayısı için referanslar. */
export const PASSENGER_STOP_INDEX = 4; // stop-5 Beylikdüzü Meydan

/** ── Güzergâh ─────────────────────────────────────────── */
export const demoRoute: RouteDetail = {
  id: 'route-avrupa-sabah',
  tenant_id: DEMO_TENANT_ID,
  name: 'Avrupa Yakası Sabah Güzergâhı',
  direction: ROUTE_DIRECTION.MORNING,
  start_location: 'Esenyurt Merkez',
  end_location: 'Atlas Plaza',
  encoded_polyline: null,
  estimated_distance: 22400,
  estimated_duration: 45,
  status: 'active',
  stop_count: demoStops.length,
  stops: demoStops,
};

/**
 * Simülasyon yolu: duraklar arasına ara noktalar eklenerek
 * aracın yumuşak hareket etmesini sağlayan koordinat dizisi.
 */
export const demoSimulationPath: LatLng[] = buildPath(demoStops);

function buildPath(stops: Stop[]): LatLng[] {
  const path: LatLng[] = [];
  for (let i = 0; i < stops.length - 1; i++) {
    const a = stops[i]!;
    const b = stops[i + 1]!;
    const segments = 8; // her durak arası 8 ara nokta
    for (let s = 0; s < segments; s++) {
      const t = s / segments;
      path.push({
        latitude: a.latitude + (b.latitude - a.latitude) * t,
        longitude: a.longitude + (b.longitude - a.longitude) * t,
      });
    }
  }
  path.push({ latitude: stops[stops.length - 1]!.latitude, longitude: stops[stops.length - 1]!.longitude });
  return path;
}

/** ── Aktif Servis Yolculuğu ───────────────────────────── */
export const demoTrip: ServiceTrip = {
  id: 'trip-today-avrupa',
  tenant_id: DEMO_TENANT_ID,
  service_definition_id: 'svc-avrupa-sabah',
  service_name: 'Avrupa Yakası Sabah Servisi',
  service_date: '2026-08-02',
  direction: ROUTE_DIRECTION.MORNING,
  route_id: demoRoute.id,
  route_name: demoRoute.name,
  driver_id: DEMO_DRIVER_ID,
  driver_name: 'Mehmet Yılmaz',
  vehicle_id: demoVehicle.id,
  vehicle_plate: demoVehicle.plate_number,
  planned_start_at: '2026-08-02T06:30:00Z',
  actual_start_at: '2026-08-02T06:33:00Z',
  planned_end_at: '2026-08-02T07:15:00Z',
  actual_end_at: null,
  current_stop_id: 'stop-1',
  next_stop_id: 'stop-2',
  status: TRIP_STATUS.ACTIVE,
  delay_minutes: 3,
  total_distance: 22400,
  passenger_count: 17,
  stop_count: demoStops.length,
};

/** ── Yolcular (17 adet, duraklara dağıtılmış) ─────────── */
const passengerSeed: Array<[string, number]> = [
  ['Zeynep Arslan', 4], // yolcu@demo.com — stop-5
  ['Emre Şahin', 0],
  ['Elif Yıldız', 0],
  ['Burak Koç', 1],
  ['Ayşe Aydın', 1],
  ['Can Öztürk', 2],
  ['Merve Doğan', 2],
  ['Deniz Kurt', 2],
  ['Kaan Çelik', 3],
  ['Selin Aslan', 3],
  ['Okan Polat', 4],
  ['Buse Erdoğan', 4],
  ['Tolga Şen', 5],
  ['Nur Bulut', 5],
  ['Hakan Acar', 6],
  ['Ceren Kılıç', 6],
  ['Mert Tuna', 7],
];

export const demoTripPassengers: TripPassenger[] = passengerSeed.map(([name, stopIdx], i) => {
  const stop = demoStops[stopIdx]!;
  const isDemoPassenger = i === 0;
  return {
    id: `tp-${i + 1}`,
    service_trip_id: demoTrip.id,
    passenger_id: isDemoPassenger ? DEMO_PASSENGER_ID : `pax-${i + 1}`,
    passenger_name: name,
    stop_id: stop.id,
    stop_name: stop.name,
    // Geçmiş duraklardaki yolcular bindi kabul edilir (simülasyon başlangıç durumu)
    boarding_status: stopIdx < PASSENGER_STOP_INDEX ? BOARDING_STATUS.EXPECTED : BOARDING_STATUS.EXPECTED,
    boarded_at: null,
    driver_note: null,
  };
});

/** Yolcu ekranı için başlangıç anlık verileri (senaryo değerleri). */
export const demoPassengerSnapshot = {
  tripId: demoTrip.id,
  passengerStopId: demoStops[PASSENGER_STOP_INDEX]!.id,
  passengerStopName: demoStops[PASSENGER_STOP_INDEX]!.name, // Beylikdüzü Meydan
  remainingStops: 4,
  etaMinutes: 12,
  delayMinutes: 3,
} as const;
