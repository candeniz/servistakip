import '../../core/constants/roles.dart';
import '../models/auth_models.dart';

/// Mock giriş için demo hesap (şifre dahil — yalnızca mock katmanı).
class DemoAccount {
  const DemoAccount(this.password, this.user);
  final String password;
  final AuthUser user;
}

const demoTenantId = 'tenant-atlas';
const demoTenantName = 'Atlas Teknoloji';
const demoDriverId = 'user-driver';
const demoPassengerId = 'user-passenger';

/// Tüm demo hesapların ortak şifresi.
const demoPassword = 'Demo123!';

AuthUser _u(String id, Role role, String first, String last, String email,
        {String? tenant, String? tenantName}) =>
    AuthUser(
      id: id,
      tenantId: tenant,
      firstName: first,
      lastName: last,
      email: email,
      phone: '+90 555 000 0000',
      role: role,
      status: 'active',
      profilePhoto: null,
      tenantName: tenantName,
    );

/// Dört demo hesap — hepsi Demo123! şifresiyle.
final List<DemoAccount> demoAccounts = [
  DemoAccount(demoPassword,
      _u('user-superadmin', Role.superAdmin, 'Selin', 'Kaya', 'superadmin@demo.com')),
  DemoAccount(
      demoPassword,
      _u('user-admin', Role.companyAdmin, 'Ahmet', 'Demir', 'yonetici@demo.com',
          tenant: demoTenantId, tenantName: demoTenantName)),
  DemoAccount(
      demoPassword,
      _u(demoDriverId, Role.driver, 'Mehmet', 'Yılmaz', 'sofor@demo.com',
          tenant: demoTenantId, tenantName: demoTenantName)),
  DemoAccount(
      demoPassword,
      _u(demoPassengerId, Role.passenger, 'Zeynep', 'Arslan', 'yolcu@demo.com',
          tenant: demoTenantId, tenantName: demoTenantName)),
];
