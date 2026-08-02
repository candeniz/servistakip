import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Grafik çubuğu verisi.
class BarDatum {
  const BarDatum({required this.label, required this.value, this.highlight});
  final String label;
  final double value;

  /// null: nötr gri. true: mavi vurgu. false: turuncu (gecikme) vurgu.
  final bool? highlight;
}

/// Harici paket gerektirmeyen basit dikey bar grafik (Stitch sefer istatistiği).
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key, required this.data, this.height = 180});

  final List<BarDatum> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(1, (m, d) => d.value > m ? d.value : m);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (d.highlight != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: d.highlight! ? AppColors.primary : AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${d.value.toInt()}',
                            style: AppText.monoTiny.copyWith(color: AppColors.textInverse)),
                      ),
                    Container(
                      height: (height - 40) * (d.value / maxValue),
                      decoration: BoxDecoration(
                        color: switch (d.highlight) {
                          true => AppColors.primary,
                          false => AppColors.warning,
                          null => AppColors.surfaceAlt,
                        },
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(d.label,
                        style: AppText.monoTiny.copyWith(fontSize: 9),
                        maxLines: 1, overflow: TextOverflow.clip),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
