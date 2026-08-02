import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_card.dart';

enum StatTone { normal, success, warning, danger }

/// Küçük istatistik kartı (dashboard).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.tone = StatTone.normal,
  });

  final String label;
  final String value;
  final String? hint;
  final StatTone tone;

  Color get _color => switch (tone) {
        StatTone.normal => AppColors.text,
        StatTone.success => AppColors.success,
        StatTone.warning => AppColors.warning,
        StatTone.danger => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppText.display.copyWith(fontSize: 26, height: 1.1, color: _color),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: AppText.tiny),
          ],
        ],
      ),
    );
  }
}
