import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/service_trip.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Servis/yolculuk özet kartı (listelerde).
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.trip, this.onTap});

  final ServiceTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(trip.serviceName, style: AppText.h3, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge.trip(trip.status),
            ],
          ),
          const SizedBox(height: 2),
          Text('${trip.routeName} · ${trip.direction.label}', style: AppText.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _meta('Araç', trip.vehiclePlate),
              _meta('Şoför', trip.driverName),
              _meta('Kalkış', Fmt.time(trip.plannedStartAt)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${trip.passengerCount} yolcu · ${trip.stopCount} durak', style: AppText.tiny),
              if (trip.delayMinutes > 0)
                Text('${trip.delayMinutes} dk gecikme',
                    style: AppText.tiny.copyWith(color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.tiny),
            Text(value, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
