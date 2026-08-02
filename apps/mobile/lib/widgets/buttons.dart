import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

enum ButtonVariant { primary, success, danger }

/// Birincil dolgulu buton.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final ButtonVariant variant;

  Color get _bg => switch (variant) {
        ButtonVariant.primary => AppColors.primary,
        ButtonVariant.success => AppColors.success,
        ButtonVariant.danger => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _bg,
          disabledBackgroundColor: _bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: AppText.bodyStrong.copyWith(color: AppColors.textInverse)),
      ),
    );
  }
}

/// İkincil (çerçeveli) buton.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Text(label, style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
      ),
    );
  }
}
