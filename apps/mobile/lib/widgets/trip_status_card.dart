import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/service_trip.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Aktif servisin özet başlık kartı (şoför/yönetici).
class TripStatusCard extends StatelessWidget {
  const TripStatusCard({super.key, required this.trip});
  final ServiceTrip trip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(trip.serviceName, style: AppText.h2, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge.trip(trip.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(trip.routeName, style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _info('Plaka', trip.vehiclePlate, null),
              _info('Başlangıç', Fmt.time(trip.actualStartAt ?? trip.plannedStartAt), null),
              _info('Gecikme', trip.delayMinutes > 0 ? '${trip.delayMinutes} dk' : 'Yok',
                  trip.delayMinutes > 0 ? AppColors.warning : AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, Color? color) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.tiny),
            Text(value, style: AppText.bodyStrong.copyWith(color: color)),
          ],
        ),
      );
}
