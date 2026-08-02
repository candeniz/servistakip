import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Stitch buton varyantları:
/// - navy  : koyu lacivert ana CTA ("GİRİŞ YAP", "VARIŞTA BİLDİR")
/// - primary: mavi birincil aksiyon ("+ YENİ KAYIT")
/// - success/danger: durum aksiyonları
enum ButtonVariant { navy, primary, success, danger }

/// Birincil dolgulu buton — mono, büyük harf etiket.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = ButtonVariant.navy,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final ButtonVariant variant;
  final IconData? icon;

  Color get _bg => switch (variant) {
        ButtonVariant.navy => AppColors.primaryDark,
        ButtonVariant.primary => AppColors.primary,
        ButtonVariant.success => AppColors.success,
        ButtonVariant.danger => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _bg,
          disabledBackgroundColor: _bg.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label.toUpperCase(),
                      style: AppText.monoStrong.copyWith(color: AppColors.textInverse, letterSpacing: 1.2)),
                  if (icon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(icon, size: 18, color: AppColors.textInverse),
                  ],
                ],
              ),
      ),
    );
  }
}

/// İkincil (çerçeveli) buton.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: AppSpacing.sm)],
            Text(label.toUpperCase(),
                style: AppText.monoStrong.copyWith(color: AppColors.primary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
