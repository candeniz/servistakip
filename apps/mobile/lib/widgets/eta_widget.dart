import 'package:flutter/material.dart';

import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/eta_result.dart';

/// Yolcu ekranında tahmini varış bilgilerini gösteren pano.
class EtaWidget extends StatelessWidget {
  const EtaWidget({super.key, required this.eta});
  final EtaResult eta;

  @override
  Widget build(BuildContext context) {
    final delayed = eta.delayMinutes > 0;
    final onPrimary = AppColors.textInverse.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(Fmt.minutes(eta.etaMinutes),
              style: AppText.display.copyWith(fontSize: 40, color: AppColors.textInverse)),
          Text(S.eta, style: AppText.caption.copyWith(color: onPrimary)),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _metric(S.remainingStops, '${eta.remainingStops}', AppColors.text),
                _metric(S.remainingDistance, Fmt.distance(eta.remainingDistanceMeters), AppColors.text),
                _metric(S.delay, delayed ? Fmt.minutes(eta.delayMinutes) : 'Yok',
                    delayed ? AppColors.warning : AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Planlanan: ${Fmt.time(eta.plannedArrivalAt)}',
                  style: AppText.tiny.copyWith(color: onPrimary)),
              Text('Güncel: ${Fmt.time(eta.estimatedArrivalAt)}',
                  style: AppText.tiny.copyWith(color: delayed ? AppColors.warningBg : onPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(value, style: AppText.h2.copyWith(color: color)),
            Text(label, style: AppText.tiny, textAlign: TextAlign.center),
          ],
        ),
      );
}
