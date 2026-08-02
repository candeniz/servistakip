import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/roles.dart';
import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/auth_models.dart';
import '../features/auth/company_code_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/kvkk_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/new_password_screen.dart';
import '../features/auth/permissions_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/auth/welcome_screen.dart';
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
import '../features/driver/trip_summary_screen.dart';
import '../features/passenger/absent_screen.dart';
import '../features/passenger/passenger_screens.dart';
import '../features/shell/role_shell.dart';
import '../features/super_admin/customer_detail_screen.dart';
import '../features/super_admin/new_customer_wizard_screen.dart';
import '../features/super_admin/package_management_screen.dart';
import '../features/super_admin/super_admin_screens.dart';
import '../providers/auth_provider.dart';

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

  const authRoutes = {
    '/', '/welcome', '/login', '/forgot-password', '/verify-code', '/company-code', '/kvkk', '/new-password',
  };

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
        // Giriş yapılmamış → yalnızca auth rotalarına izin ver, giriş noktası: karşılama.
        return atAuthRoute ? (loc == '/' ? '/welcome' : null) : '/welcome';
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
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-code', builder: (_, _) => const VerifyCodeScreen()),
      GoRoute(path: '/new-password', builder: (_, _) => const NewPasswordScreen()),
      GoRoute(path: '/company-code', builder: (_, _) => const CompanyCodeScreen()),
      GoRoute(path: '/kvkk', builder: (_, _) => const KvkkScreen()),
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
      GoRoute(path: '/trip-summary', builder: (_, _) => const TripSummaryScreen()),
      GoRoute(path: '/absent', builder: (_, _) => const AbsentScreen()),

      _superAdminShell(),
      _companyAdminShell(),
      _driverShell(),
      _passengerShell(),
    ],
  );
});

/// Konumun kullanıcının rolü için izinli olup olmadığı.
bool _allowedForRole(String loc, AuthUser user) {
  const detailPrefixes = ['/trip', '/customer', '/new-trip', '/reports', '/routes', '/route-builder', '/users', '/schedule', '/new-customer', '/announcement', '/incident', '/trip-summary', '/absent', '/permissions'];
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

/// Açılış / rol geçiş ekranı (Stitch): marka + araç görseli + hazırlanıyor kartı.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(S.appName, style: AppText.h1),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_user, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('SİSTEM GÜVENLİ', style: AppText.monoTiny.copyWith(fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: AppSpacing.huge),
            Container(
              width: 110, height: 110, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(28)),
              child: Container(
                width: 80, height: 80, alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 40),
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
                boxShadow: const [BoxShadow(color: Color(0x0A0B1C30), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Column(children: [
                Text('Panele Yönlendiriliyorsunuz…', style: AppText.h3, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text('Sistem verileri ve güzergah bilgileriniz hazırlanıyor. Lütfen bekleyiniz.',
                    style: AppText.caption, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 6,
                        backgroundColor: AppColors.surfaceAlt, color: AppColors.primary)),
                const SizedBox(height: AppSpacing.md),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                      child: Text('ID: #082X-L', style: AppText.monoTiny)),
                  const SizedBox(width: AppSpacing.sm),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('CANLI BAĞLANTI', style: AppText.monoTiny),
                      ])),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
