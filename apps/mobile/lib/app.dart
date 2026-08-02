import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/core_providers.dart';
import 'router/app_router.dart';

/// Kök uygulama widget'ı — MaterialApp.router + tema + Riverpod.
class ServisTakipApp extends ConsumerStatefulWidget {
  const ServisTakipApp({super.key});

  @override
  ConsumerState<ServisTakipApp> createState() => _ServisTakipAppState();
}

class _ServisTakipAppState extends ConsumerState<ServisTakipApp> {
  @override
  void initState() {
    super.initState();
    // FCM bildirim servisini başlat (izin + token). Firebase yoksa güvenli atlar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
