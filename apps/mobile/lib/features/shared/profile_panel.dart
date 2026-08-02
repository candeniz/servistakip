import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/user_avatar.dart';

/// Tüm rollerin profil/ayarlar ekranında paylaşılan panel.
class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Row(
            children: [
              UserAvatar(name: user.fullName, photoUrl: user.profilePhoto, size: 64),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: AppText.h2),
                    Text(user.email, style: AppText.caption),
                    Text(user.role.label, style: AppText.label.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (user.tenantName != null)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ŞİRKET', style: AppText.label),
                Text(user.tenantName!, style: AppText.bodyStrong),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: S.logout,
          variant: ButtonVariant.danger,
          onPressed: () async {
            final ok = await showConfirmationDialog(
              context,
              title: 'Çıkış yapılsın mı?',
              message: 'Oturumunuz kapatılacak.',
              confirmLabel: S.logout,
              destructive: true,
            );
            if (ok) {
              await ref.read(authControllerProvider.notifier).logout();
            }
          },
        ),
      ],
    );
  }
}
