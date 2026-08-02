import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_card.dart';

/// 2 sütunlu kompakt istatistik kartı (Stitch süper admin grid'i):
/// mono etiket + büyük değer + sağ üstte küçük vurgu (yüzde/ikon/çip).
class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;

  /// Sağ üstteki küçük gösterge (ör. "+2.4%", ikon, çip).
  final Widget? accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.monoLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(value,
                    style: AppText.statValue.copyWith(fontSize: 30),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (accent != null) Padding(padding: const EdgeInsets.only(left: 4, bottom: 4), child: accent!),
            ],
          ),
        ],
      ),
    );
  }
}

/// Yüzde değişim etiketi (yeşil/kırmızı).
class DeltaTag extends StatelessWidget {
  const DeltaTag({super.key, required this.text, this.positive = true});
  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppText.monoTiny.copyWith(
            color: positive ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700));
  }
}

/// Küçük bilgi çipi (ör. "GENEL").
class MiniChip extends StatelessWidget {
  const MiniChip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(4)),
      child: Text(label.toUpperCase(),
          style: AppText.monoTiny.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}
