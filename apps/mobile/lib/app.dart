import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Kök uygulama widget'ı — MaterialApp.router + tema + Riverpod.
class ServisTakipApp extends ConsumerWidget {
  const ServisTakipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
