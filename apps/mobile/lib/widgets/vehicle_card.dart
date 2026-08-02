import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/vehicle.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Araç özet kartı.
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (vehicle.status) {
      'active' => ('Aktif', BadgeTone.success),
      'maintenance' => ('Bakımda', BadgeTone.warning),
      _ => ('Pasif', BadgeTone.neutral),
    };
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.plateNumber, style: AppText.h3),
                Text('${vehicle.brand} ${vehicle.model} · ${vehicle.capacity} kişilik',
                    style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(label: label, tone: tone),
        ],
      ),
    );
  }
}
