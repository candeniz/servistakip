import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Plaka çipi — açık mavi dolgu üzerinde mono yazı (Stitch tasarımı).
class PlateChip extends StatelessWidget {
  const PlateChip({super.key, required this.plate, this.dense = false});

  final String plate;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        plate,
        style: AppText.monoStrong.copyWith(
          fontSize: dense ? 12 : 14,
          color: AppColors.primaryDark,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
