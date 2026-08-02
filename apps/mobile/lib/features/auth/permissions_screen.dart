import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Konum ve bildirim izinlerini toplayan onboarding ekranı.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool? _location;
  bool? _notifications;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'İzinler',
      subtitle: 'Servis takibi için gerekli izinler',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('📍 Konum İzni', style: AppText.h3),
              const SizedBox(height: AppSpacing.xs),
              const Text('Şoförler için canlı konum paylaşımı ve yolcular için harita gösterimi.',
                  style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: _location == true ? 'Konum izni verildi ✓' : 'Konum İznini Ver',
                onPressed: () async {
                  final granted = await ref.read(locationServiceProvider).requestPermission();
                  if (mounted) setState(() => _location = granted);
                },
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🔔 Bildirim İzni', style: AppText.h3),
              const SizedBox(height: AppSpacing.xs),
              const Text('Servis yaklaşınca, geciktiğinde ve duyurular için anlık bildirim.',
                  style: AppText.caption),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: _notifications == true ? 'Bildirim izni verildi ✓' : 'Bildirim İznini Ver',
                onPressed: () async {
                  await ref.read(notificationServiceProvider).init();
                  if (mounted) setState(() => _notifications = true);
                },
              ),
            ],
          ),
        ),
        PrimaryButton(label: 'Devam Et', onPressed: () => context.pop()),
      ],
    );
  }
}
