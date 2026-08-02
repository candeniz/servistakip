import 'package:flutter/material.dart';

import '../core/constants/statuses.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/service_trip.dart';
import 'app_card.dart';
import 'status_badge.dart';
import 'user_avatar.dart';

/// Duraktaki yolcu satırı — şoför biniş durumunu işaretler.
class PassengerRow extends StatelessWidget {
  const PassengerRow({super.key, required this.passenger, this.onSetStatus});

  final TripPassenger passenger;
  final void Function(BoardingStatus)? onSetStatus;

  static const _actions = [
    (BoardingStatus.boarded, 'Bindi'),
    (BoardingStatus.noShow, 'Gelmedi'),
    (BoardingStatus.absent, 'İzinli'),
    (BoardingStatus.wrongStop, 'Yanlış'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: passenger.passengerName, size: 38),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passenger.passengerName, style: AppText.bodyStrong),
                    Text(passenger.stopName, style: AppText.tiny),
                  ],
                ),
              ),
              StatusBadge.boarding(passenger.boardingStatus),
            ],
          ),
          if (onSetStatus != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final (status, label) in _actions) _actionButton(status, label),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(BoardingStatus status, String label) {
    final active = passenger.boardingStatus == status;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: () => onSetStatus?.call(status),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: AppText.label.copyWith(
                color: active ? AppColors.textInverse : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
