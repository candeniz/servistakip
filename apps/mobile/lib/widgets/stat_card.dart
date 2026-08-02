import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_card.dart';

enum StatTone { normal, success, warning, danger, primary }

Color _toneColor(StatTone tone) => switch (tone) {
      StatTone.normal => AppColors.text,
      StatTone.success => AppColors.success,
      StatTone.warning => AppColors.warning,
      StatTone.danger => AppColors.danger,
      StatTone.primary => AppColors.primary,
    };

/// İstatistik kartı (Stitch): mono büyük-harf etiket + büyük değer + opsiyonel
/// sol vurgu şeridi ve alt renkli satır.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.tone = StatTone.normal,
    this.accentColor,
    this.subLabel,
    this.subTone = StatTone.primary,
  });

  final String label;
  final String value;
  final String? hint;
  final StatTone tone;
  final Color? accentColor;
  final String? subLabel;
  final StatTone subTone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.monoLabel),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppText.statValue.copyWith(fontSize: 34, color: _toneColor(tone)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subLabel!, style: AppText.bodyStrong.copyWith(color: _toneColor(subTone))),
          ],
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: AppText.monoTiny),
          ],
        ],
      ),
    );
  }
}
