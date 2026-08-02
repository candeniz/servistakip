import '../../core/constants/statuses.dart';

/// Müşteri şirket (tenant).
class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    required this.companyCode,
    required this.primaryColor,
    required this.status,
    required this.userLimit,
    required this.vehicleLimit,
    required this.activeUserCount,
    required this.activeTripCount,
  });

  final String id;
  final String name;
  final String companyCode;
  final String? primaryColor;
  final TenantStatus status;
  final int userLimit;
  final int vehicleLimit;
  final int activeUserCount;
  final int activeTripCount;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        id: json['id'] as String,
        name: json['name'] as String,
        companyCode: json['company_code'] as String,
        primaryColor: json['primary_color'] as String?,
        status: TenantStatus.fromValue(json['status'] as String? ?? 'active'),
        userLimit: (json['user_limit'] as num?)?.toInt() ?? 0,
        vehicleLimit: (json['vehicle_limit'] as num?)?.toInt() ?? 0,
        activeUserCount: (json['active_user_count'] as num?)?.toInt() ?? 0,
        activeTripCount: (json['active_trip_count'] as num?)?.toInt() ?? 0,
      );
}
