import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/eta/eta_provider.dart';
import '../data/eta/mock_eta_provider.dart';
import '../data/services/auth_service.dart';
import '../data/services/data_service.dart';
import '../data/services/dio_client.dart';
import '../data/services/location_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/token_store.dart';

/// Güvenli token deposu (testlerde InMemoryTokenStore ile override edilebilir).
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

/// Dio istemcisi — 401'de oturum kapatma kancasıyla.
final dioClientProvider = Provider<DioClient>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return DioClient(
    tokenStore: store,
    onSessionExpired: () {
      // authController hydrate/logout ile bağlanır (auth_provider içinde dinlenir).
      ref.read(sessionExpiredProvider.notifier).state++;
    },
  );
});

/// Oturum sona erdiğinde artan sayaç (auth controller dinler).
final sessionExpiredProvider = StateProvider<int>((ref) => 0);

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return createAuthService(dio);
});

final dataServiceProvider = Provider<DataService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return DataService(dio);
});

final etaProviderProvider = Provider<EtaProvider>((ref) => MockEtaProvider());

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
