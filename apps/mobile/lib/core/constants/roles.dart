/// Sistem rolleri — backend JWT `role` claim'i ile birebir eşleşir.
enum Role {
  superAdmin('super_admin'),
  companyAdmin('company_admin'),
  operationsManager('operations_manager'),
  driver('driver'),
  passenger('passenger');

  const Role(this.value);

  /// Backend/DB'de saklanan string değeri.
  final String value;

  static Role fromValue(String value) {
    return Role.values.firstWhere(
      (r) => r.value == value,
      orElse: () => Role.passenger,
    );
  }

  /// Türkçe etiket (UI).
  String get label => switch (this) {
        Role.superAdmin => 'Süper Admin',
        Role.companyAdmin => 'Yönetici',
        Role.operationsManager => 'Operasyon Yetkilisi',
        Role.driver => 'Şoför',
        Role.passenger => 'Yolcu',
      };

  /// Giriş sonrası yönlendirilecek ana rota. operations_manager, yönetici
  /// arayüzünü paylaşır.
  String get homeRoute => switch (this) {
        Role.superAdmin => '/super-admin',
        Role.companyAdmin => '/admin',
        Role.operationsManager => '/admin',
        Role.driver => '/driver',
        Role.passenger => '/passenger',
      };
}
