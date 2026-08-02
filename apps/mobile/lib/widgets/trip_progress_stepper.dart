import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Yolculuk süreci adım göstergesi (Stitch: DEPO → YOLDA → DURAK).
class TripProgressStepper extends StatelessWidget {
  const TripProgressStepper({super.key, required this.steps, required this.activeIndex});

  /// Adım etiketleri (ör. ['DEPO', 'YOLDA', 'DURAK']).
  final List<String> steps;

  /// Aktif adım index'i (bu ve öncesi tamamlanmış sayılır).
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _dotWithLabel(steps[i], i <= activeIndex),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                color: i < activeIndex ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }

  Widget _dotWithLabel(String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
            border: active ? Border.all(color: AppColors.primaryLight, width: 3) : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(label.toUpperCase(),
            style: AppText.monoTiny.copyWith(
                color: active ? AppColors.primary : AppColors.textMuted,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
