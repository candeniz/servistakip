import 'package:flutter/material.dart';

import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'buttons.dart';

/// Tam ekran yükleniyor göstergesi.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = S.loading});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppText.caption),
        ],
      ),
    );
  }
}

/// Hata durumu görünümü + opsiyonel tekrar dene.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, this.title = S.genericError, this.description, this.onRetry});
  final String title;
  final String? description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppText.h3, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(description!, style: AppText.caption, textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: S.retry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

/// Boş liste / veri yok durumu.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, this.title = S.noData, this.description, this.icon = '📭'});
  final String title;
  final String? description;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description!, style: AppText.caption, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Bağlantı / durum uyarı şeridi.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.message, this.tone = BannerTone.danger});
  final String message;
  final BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final bg = tone == BannerTone.danger ? AppColors.dangerBg : AppColors.warningBg;
    final fg = tone == BannerTone.danger ? AppColors.danger : AppColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Text(message,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

enum BannerTone { danger, warning }
