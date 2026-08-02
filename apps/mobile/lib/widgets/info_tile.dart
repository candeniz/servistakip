import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// 2×2 bilgi kutusu (Stitch): ikon + mono büyük-harf etiket + değer.
/// Açık mavi dolgulu, yuvarlak köşeli tile.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  /// Değer yerine özel widget (ör. PlateChip).
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTile,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label.toUpperCase(), style: AppText.monoLabel,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          valueWidget ??
              Text(value,
                  style: AppText.h2.copyWith(color: valueColor ?? AppColors.text),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
