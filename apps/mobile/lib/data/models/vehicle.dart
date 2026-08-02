/// Araç.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.tenantId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.capacity,
    required this.vehicleType,
    required this.status,
  });

  final String id;
  final String tenantId;
  final String plateNumber;
  final String brand;
  final String model;
  final int year;
  final int capacity;
  final String vehicleType;
  final String status;

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        plateNumber: json['plate_number'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: (json['year'] as num?)?.toInt() ?? 2020,
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        vehicleType: json['vehicle_type'] as String? ?? 'minibus',
        status: json['status'] as String? ?? 'active',
      );
}
