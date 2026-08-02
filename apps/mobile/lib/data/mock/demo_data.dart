import '../../core/constants/statuses.dart';
import '../../core/constants/ws_channels.dart';
import '../../core/utils/geo.dart';
import '../models/service_route.dart';
import '../models/service_trip.dart';
import '../models/stop.dart';
import '../models/tenant.dart';
import '../models/vehicle.dart';
import 'demo_users.dart';

/// Yolcunun (Zeynep) durağının index'i — Beylikdüzü Meydan.
const passengerStopIndex = 4;

/// ── Tenant'lar ──────────────────────────────────────────
final demoTenant = Tenant(
  id: demoTenantId,
  name: 'Atlas Teknoloji',
  companyCode: 'ATLAS01',
  primaryColor: '#1E5EFF',
  status: TenantStatus.active,
  userLimit: 250,
  vehicleLimit: 20,
  activeUserCount: 143,
  activeTripCount: 6,
);

final List<Tenant> demoTenants = [
  demoTenant,
  Tenant(
    id: 'tenant-nova',
    name: 'Nova Lojistik',
    companyCode: 'NOVA02',
    primaryColor: '#1DAA6D',
    status: TenantStatus.active,
    userLimit: 120,
    vehicleLimit: 12,
    activeUserCount: 88,
    activeTripCount: 3,
  ),
  Tenant(
    id: 'tenant-delta',
    name: 'Delta Üretim',
    companyCode: 'DELTA03',
    primaryColor: '#F2A007',
    status: TenantStatus.suspended,
    userLimit: 60,
    vehicleLimit: 6,
    activeUserCount: 0,
    activeTripCount: 0,
  ),
];

/// ── Araçlar ─────────────────────────────────────────────
final demoVehicle = Vehicle(
  id: 'vehicle-34st2026',
  tenantId: demoTenantId,
  plateNumber: '34 ST 2026',
  brand: 'Mercedes-Benz',
  model: 'Sprinter',
  year: 2023,
  capacity: 19,
  vehicleType: 'minibus',
  status: 'active',
);

final List<Vehicle> demoVehicles = [
  demoVehicle,
  Vehicle(
    id: 'vehicle-34xy1400',
    tenantId: demoTenantId,
    plateNumber: '34 XY 1400',
    brand: 'Ford',
    model: 'Transit',
    year: 2022,
    capacity: 16,
    vehicleType: 'minibus',
    status: 'active',
  ),
];

/// ── Duraklar (8 adet) — Avrupa Yakası sabah güzergâhı ───
final List<Stop> demoStops = () {
  const raw = [
    ['stop-1', 'Esenyurt Merkez', 41.0341, 28.6800, 0],
    ['stop-2', 'Haramidere', 41.0200, 28.6620, 6],
    ['stop-3', 'Beylikdüzü Cumhuriyet', 41.0070, 28.6460, 12],
    ['stop-4', 'Gürpınar Sahil', 40.9970, 28.6360, 18],
    ['stop-5', 'Beylikdüzü Meydan', 41.0030, 28.6410, 24], // yolcunun durağı
    ['stop-6', 'Yakuplu', 41.0120, 28.6570, 30],
    ['stop-7', 'Beylikdüzü E-5', 41.0260, 28.6710, 36],
    ['stop-8', 'Atlas Plaza (Varış)', 41.0450, 28.7020, 45],
  ];
  return [
    for (var i = 0; i < raw.length; i++)
      Stop(
        id: raw[i][0] as String,
        tenantId: demoTenantId,
        routeId: 'route-avrupa-sabah',
        name: raw[i][1] as String,
        latitude: raw[i][2] as double,
        longitude: raw[i][3] as double,
        orderIndex: i,
        plannedArrivalOffset: raw[i][4] as int,
        radiusMeters: RealtimeConfig.defaultStopRadiusM,
      ),
  ];
}();

/// ── Güzergâh ────────────────────────────────────────────
final demoRoute = ServiceRoute(
  id: 'route-avrupa-sabah',
  tenantId: demoTenantId,
  name: 'Avrupa Yakası Sabah Güzergâhı',
  direction: RouteDirection.morning,
  startLocation: 'Esenyurt Merkez',
  endLocation: 'Atlas Plaza',
  estimatedDistance: 22400,
  estimatedDuration: 45,
  stops: demoStops,
);

/// Simülasyon yolu: duraklar arasına 8'er ara nokta.
const simulationSegmentsPerStop = 8;

final List<LatLngPoint> demoSimulationPath = () {
  final path = <LatLngPoint>[];
  for (var i = 0; i < demoStops.length - 1; i++) {
    final a = demoStops[i];
    final b = demoStops[i + 1];
    for (var s = 0; s < simulationSegmentsPerStop; s++) {
      final t = s / simulationSegmentsPerStop;
      path.add(LatLngPoint(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      ));
    }
  }
  final last = demoStops.last;
  path.add(LatLngPoint(last.latitude, last.longitude));
  return path;
}();

/// ── Aktif yolculuk ──────────────────────────────────────
final demoTrip = ServiceTrip(
  id: 'trip-today-avrupa',
  tenantId: demoTenantId,
  serviceName: 'Avrupa Yakası Sabah Servisi',
  serviceDate: '2026-08-02',
  direction: RouteDirection.morning,
  routeId: demoRoute.id,
  routeName: demoRoute.name,
  driverId: demoDriverId,
  driverName: 'Mehmet Yılmaz',
  vehicleId: demoVehicle.id,
  vehiclePlate: demoVehicle.plateNumber,
  plannedStartAt: DateTime.parse('2026-08-02T06:30:00Z'),
  actualStartAt: DateTime.parse('2026-08-02T06:33:00Z'),
  plannedEndAt: DateTime.parse('2026-08-02T07:15:00Z'),
  nextStopId: 'stop-2',
  status: TripStatus.active,
  delayMinutes: 3,
  totalDistance: 22400,
  passengerCount: 17,
  stopCount: 8,
);

/// Yönetici liste/tablolarını doldurmak için ek örnek yolculuklar.
final List<ServiceTrip> demoTrips = [
  demoTrip,
  ServiceTrip(
    id: 'trip-besiktas',
    tenantId: demoTenantId,
    serviceName: 'Beşiktaş – Ümraniye',
    serviceDate: '2026-08-02',
    direction: RouteDirection.morning,
    routeId: demoRoute.id,
    routeName: 'Beşiktaş – Ümraniye Hattı',
    driverId: 'driver-murat',
    driverName: 'Murat S.',
    vehicleId: 'vehicle-34xy1400',
    vehiclePlate: '34 ABC 456',
    plannedStartAt: DateTime.parse('2026-08-02T06:45:00Z'),
    actualStartAt: DateTime.parse('2026-08-02T06:45:00Z'),
    plannedEndAt: DateTime.parse('2026-08-02T07:30:00Z'),
    nextStopId: null,
    status: TripStatus.completed,
    delayMinutes: 0,
    totalDistance: 18000,
    passengerCount: 14,
    stopCount: 7,
  ),
  ServiceTrip(
    id: 'trip-kartal',
    tenantId: demoTenantId,
    serviceName: 'Kartal – Maltepe Ring',
    serviceDate: '2026-08-02',
    direction: RouteDirection.morning,
    routeId: demoRoute.id,
    routeName: 'Kartal – Maltepe Ring',
    driverId: 'driver-caner',
    driverName: 'Caner K.',
    vehicleId: 'vehicle-34def789',
    vehiclePlate: '34 DEF 789',
    plannedStartAt: DateTime.parse('2026-08-02T09:15:00Z'),
    actualStartAt: null,
    plannedEndAt: DateTime.parse('2026-08-02T10:00:00Z'),
    nextStopId: null,
    status: TripStatus.scheduled,
    delayMinutes: 0,
    totalDistance: 12000,
    passengerCount: 9,
    stopCount: 5,
  ),
];

/// ── Yolcular (17) ───────────────────────────────────────
final List<TripPassenger> demoTripPassengers = () {
  const seed = [
    ['Zeynep Arslan', 4], // yolcu@demo.com
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
  return [
    for (var i = 0; i < seed.length; i++)
      TripPassenger(
        id: 'tp-${i + 1}',
        serviceTripId: demoTrip.id,
        passengerId: i == 0 ? demoPassengerId : 'pax-${i + 1}',
        passengerName: seed[i][0] as String,
        stopId: demoStops[seed[i][1] as int].id,
        stopName: demoStops[seed[i][1] as int].name,
        boardingStatus: BoardingStatus.expected,
        boardedAt: null,
      ),
  ];
}();

/// Yolcu ekranı senaryo değerleri.
class PassengerSnapshot {
  const PassengerSnapshot._();
  static const remainingStops = 4;
  static const etaMinutes = 12;
  static const delayMinutes = 3;
  static String get passengerStopName => demoStops[passengerStopIndex].name;
  static String get passengerStopId => demoStops[passengerStopIndex].id;
}
