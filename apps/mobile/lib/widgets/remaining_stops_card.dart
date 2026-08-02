import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_card.dart';

/// Yolcuya kaç durak kaldığını ve durak bilgisini vurgular.
class RemainingStopsCard extends StatelessWidget {
  const RemainingStopsCard({
    super.key,
    required this.remainingStops,
    required this.passengerStopName,
    required this.nextStopName,
  });

  final int remainingStops;
  final String passengerStopName;
  final String nextStopName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Text('$remainingStops',
                style: AppText.display.copyWith(fontSize: 26, color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Durağınıza $remainingStops durak kaldı', style: AppText.bodyStrong),
                Text('Durağınız: $passengerStopName', style: AppText.caption),
                Text('Aracın sıradaki durağı: $nextStopName', style: AppText.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
