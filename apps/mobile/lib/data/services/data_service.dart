import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../mock/demo_data.dart';
import '../mock/demo_notifications.dart';
import '../models/app_notification.dart';
import '../models/service_route.dart';
import '../models/service_trip.dart';
import '../models/tenant.dart';
import '../models/vehicle.dart';

/// Liste/detay verileri için servis katmanı.
/// useMock=true iken mock verileri, aksi halde gerçek API'yi kullanır.
class DataService {
  DataService(this._dio);
  final Dio _dio;

  static Future<void> _delay() => Future<void>.delayed(const Duration(milliseconds: 250));

  Future<List<Tenant>> listTenants() async {
    if (Env.useMock) {
      await _delay();
      return demoTenants;
    }
    final res = await _dio.get<Map<String, dynamic>>('/tenants');
    return ((res.data!['items'] as List)).map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Vehicle>> listVehicles() async {
    if (Env.useMock) {
      await _delay();
      return demoVehicles;
    }
    final res = await _dio.get<Map<String, dynamic>>('/vehicles');
    return ((res.data!['items'] as List)).map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceTrip>> listTrips() async {
    if (Env.useMock) {
      await _delay();
      return demoTrips;
    }
    final res = await _dio.get<List<dynamic>>('/trips');
    return res.data!.map((e) => ServiceTrip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceTrip> getTrip(String id) async {
    if (Env.useMock) {
      await _delay();
      return demoTrip;
    }
    final res = await _dio.get<Map<String, dynamic>>('/trips/$id');
    return ServiceTrip.fromJson(res.data!);
  }

  Future<ServiceRoute> getRoute(String id) async {
    if (Env.useMock) {
      await _delay();
      return demoRoute;
    }
    final res = await _dio.get<Map<String, dynamic>>('/routes/$id');
    return ServiceRoute.fromJson(res.data!);
  }

  Future<List<TripPassenger>> listTripPassengers(String tripId) async {
    if (Env.useMock) {
      await _delay();
      return demoTripPassengers;
    }
    final res = await _dio.get<List<dynamic>>('/trips/$tripId/passengers');
    return res.data!.map((e) => TripPassenger.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// FCM cihaz token'ını backend'e kaydeder (DeviceToken). Mock modda atlanır.
  Future<void> registerDeviceToken(String token, String platform) async {
    if (Env.useMock) return;
    await _dio.post<void>('/notifications/device-tokens', data: {
      'token': token,
      'platform': platform,
    });
  }

  Future<List<AppNotification>> listNotifications() async {
    if (Env.useMock) {
      await _delay();
      return demoNotifications;
    }
    final res = await _dio.get<Map<String, dynamic>>('/passenger/notifications');
    return ((res.data!['items'] as List)).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }
}
