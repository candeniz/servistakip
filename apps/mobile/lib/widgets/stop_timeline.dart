import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/stop.dart';

/// Durakların dikey zaman çizelgesi; geçilen/aktif/bekleyen durumları gösterir.
class StopTimeline extends StatelessWidget {
  const StopTimeline({
    super.key,
    required this.stops,
    required this.nextStopIndex,
    this.highlightStopId,
  });

  final List<Stop> stops;
  final int nextStopIndex;
  final String? highlightStopId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++) _row(stops[i], i),
      ],
    );
  }

  Widget _row(Stop stop, int index) {
    final passed = index < nextStopIndex;
    final isNext = index == nextStopIndex;
    final isHighlight = stop.id == highlightStopId;
    final dotColor = passed ? AppColors.success : (isNext ? AppColors.primary : AppColors.border);
    final isLast = index == stops.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: isNext ? 16 : 12,
                height: isNext ? 16 : 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: isNext ? Border.all(color: AppColors.primaryLight, width: 3) : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: passed ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHighlight ? '${stop.name}  •  Durağınız' : stop.name,
                    style: AppText.bodyStrong.copyWith(
                      color: isHighlight
                          ? AppColors.primary
                          : (passed ? AppColors.textMuted : AppColors.text),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isNext ? 'Sıradaki durak' : (passed ? 'Geçildi' : '+${stop.plannedArrivalOffset} dk'),
                    style: AppText.tiny,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
