import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/roles.dart';
import '../data/models/auth_models.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/permissions_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/company_admin/announcement_screen.dart';
import '../features/company_admin/company_admin_screens.dart';
import '../features/company_admin/new_trip_screen.dart';
import '../features/company_admin/reports_screen.dart';
import '../features/company_admin/route_builder_screen.dart';
import '../features/company_admin/route_list_screen.dart';
import '../features/company_admin/trip_detail_screen.dart';
import '../features/company_admin/user_management_screen.dart';
import '../features/company_admin/weekly_schedule_screen.dart';
import '../features/driver/driver_screens.dart';
import '../features/driver/incident_screen.dart';
import '../features/passenger/passenger_screens.dart';
import '../features/shell/role_shell.dart';
import '../features/super_admin/customer_detail_screen.dart';
import '../features/super_admin/new_customer_wizard_screen.dart';
import '../features/super_admin/package_management_screen.dart';
import '../features/super_admin/super_admin_screens.dart';
import '../providers/auth_provider.dart';
import '../widgets/state_views.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// GoRouter'ı oturum durumuna göre yeniden değerlendiren notifier.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  const authRoutes = {'/', '/login', '/forgot-password', '/verify-code'};

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      // Oturum henüz belirlenmedi → splash'ta bekle.
      if (auth.status == AuthStatus.unknown) {
        return loc == '/' ? null : '/';
      }

      final authed = auth.status == AuthStatus.authenticated;
      final atAuthRoute = authRoutes.contains(loc);

      if (!authed) {
        // Giriş yapılmamış → yalnızca auth rotalarına izin ver.
        return atAuthRoute ? (loc == '/' ? '/login' : null) : '/login';
      }

      // Giriş yapılmış → auth/splash rotalarından rolün ana ekranına yönlendir.
      final home = auth.user!.role.homeRoute;
      if (atAuthRoute) return home;

      // Rol bazlı koruma: başka rolün alanına erişimi engelle (RoleGuard).
      if (!_allowedForRole(loc, auth.user!)) return home;

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-code', builder: (_, _) => const VerifyCodeScreen()),
      GoRoute(path: '/permissions', builder: (_, _) => const PermissionsScreen()),

      // Ortak detay rotaları (kök navigasyonda, kabuğun üstünde açılır)
      GoRoute(path: '/trip/:id', builder: (_, s) => TripDetailScreen(tripId: s.pathParameters['id']!)),
      GoRoute(path: '/customer/:id', builder: (_, s) => CustomerDetailScreen(tenantId: s.pathParameters['id']!)),
      GoRoute(path: '/new-trip', builder: (_, _) => const NewTripScreen()),
      GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(path: '/routes', builder: (_, _) => const RouteListScreen()),
      GoRoute(path: '/route-builder', builder: (_, _) => const RouteBuilderScreen()),
      GoRoute(path: '/users', builder: (_, _) => const UserManagementScreen()),
      GoRoute(path: '/schedule', builder: (_, _) => const WeeklyScheduleScreen()),
      GoRoute(path: '/new-customer', builder: (_, _) => const NewCustomerWizardScreen()),
      GoRoute(path: '/announcement', builder: (_, _) => const AnnouncementScreen()),
      GoRoute(path: '/incident', builder: (_, _) => const IncidentScreen()),

      _superAdminShell(),
      _companyAdminShell(),
      _driverShell(),
      _passengerShell(),
    ],
  );
});

/// Konumun kullanıcının rolü için izinli olup olmadığı.
bool _allowedForRole(String loc, AuthUser user) {
  const detailPrefixes = ['/trip', '/customer', '/new-trip', '/reports', '/routes', '/route-builder', '/users', '/schedule', '/new-customer', '/announcement', '/incident', '/permissions'];
  if (detailPrefixes.any(loc.startsWith)) return true; // paylaşılan detay ekranları

  final role = user.role;
  if (loc.startsWith('/super-admin')) return role == Role.superAdmin;
  if (loc.startsWith('/admin')) return role == Role.companyAdmin || role == Role.operationsManager;
  if (loc.startsWith('/driver')) return role == Role.driver;
  if (loc.startsWith('/passenger')) return role == Role.passenger;
  return true;
}

StatefulShellRoute _superAdminShell() => StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => RoleShell(
        navigationShell: shell,
        destinations: const [
          NavigationDestination(icon: Text('📊', style: TextStyle(fontSize: 20)), label: 'Genel'),
          NavigationDestination(icon: Text('🏢', style: TextStyle(fontSize: 20)), label: 'Müşteri'),
          NavigationDestination(icon: Text('🛰️', style: TextStyle(fontSize: 20)), label: 'Canlı'),
          NavigationDestination(icon: Text('📦', style: TextStyle(fontSize: 20)), label: 'Paket'),
          NavigationDestination(icon: Text('⚙️', style: TextStyle(fontSize: 20)), label: 'Ayarlar'),
        ],
      ),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/super-admin', builder: (_, _) => const SuperAdminDashboard())]),
        StatefulShellBranch(routes: [GoRoute(path: '/super-admin/customers', builder: (_, _) => const CustomersScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/super-admin/live', builder: (_, _) => const LiveOperationsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/super-admin/packages', builder: (_, _) => const PackageManagementScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/super-admin/settings', builder: (_, _) => const SuperAdminSettingsScreen())]),
      ],
    );

StatefulShellRoute _companyAdminShell() => StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => RoleShell(
        navigationShell: shell,
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Ana Sayfa'),
          NavigationDestination(icon: Text('🗺️', style: TextStyle(fontSize: 20)), label: 'Canlı'),
          NavigationDestination(icon: Text('🚌', style: TextStyle(fontSize: 20)), label: 'Servisler'),
          NavigationDestination(icon: Text('👥', style: TextStyle(fontSize: 20)), label: 'Kişiler'),
          NavigationDestination(icon: Text('⚙️', style: TextStyle(fontSize: 20)), label: 'Yönetim'),
        ],
      ),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/admin', builder: (_, _) => const AdminHomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/admin/live', builder: (_, _) => const AdminLiveScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/admin/services', builder: (_, _) => const AdminServicesScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/admin/people', builder: (_, _) => const AdminPeopleScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/admin/management', builder: (_, _) => const AdminManagementScreen())]),
      ],
    );

StatefulShellRoute _driverShell() => StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => RoleShell(
        navigationShell: shell,
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Ana Sayfa'),
          NavigationDestination(icon: Text('🚐', style: TextStyle(fontSize: 20)), label: 'Yolculuk'),
          NavigationDestination(icon: Text('👥', style: TextStyle(fontSize: 20)), label: 'Yolcular'),
          NavigationDestination(icon: Text('🔔', style: TextStyle(fontSize: 20)), label: 'Bildirimler'),
          NavigationDestination(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Profil'),
        ],
      ),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/driver', builder: (_, _) => const DriverHomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/driver/trip', builder: (_, _) => const DriverTripScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/driver/passengers', builder: (_, _) => const DriverPassengersScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/driver/notifications', builder: (_, _) => const DriverNotificationsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/driver/profile', builder: (_, _) => const DriverProfileScreen())]),
      ],
    );

StatefulShellRoute _passengerShell() => StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => RoleShell(
        navigationShell: shell,
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Ana Sayfa'),
          NavigationDestination(icon: Text('🚌', style: TextStyle(fontSize: 20)), label: 'Servisim'),
          NavigationDestination(icon: Text('🔔', style: TextStyle(fontSize: 20)), label: 'Bildirimler'),
          NavigationDestination(icon: Text('🕘', style: TextStyle(fontSize: 20)), label: 'Geçmiş'),
          NavigationDestination(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Profil'),
        ],
      ),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/passenger', builder: (_, _) => const PassengerHomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/passenger/my-service', builder: (_, _) => const MyServiceScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/passenger/notifications', builder: (_, _) => const PassengerNotificationsScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/passenger/history', builder: (_, _) => const PassengerHistoryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/passenger/profile', builder: (_, _) => const PassengerProfileScreen())]),
      ],
    );

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: LoadingState(message: 'Başlatılıyor…'));
}
