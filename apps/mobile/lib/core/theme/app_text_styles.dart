import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografi ölçeği (sistem fontu).
class AppText {
  const AppText._();

  static const display = TextStyle(fontSize: 30, height: 1.2, fontWeight: FontWeight.w700, color: AppColors.text);
  static const h1 = TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.text);
  static const h2 = TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w700, color: AppColors.text);
  static const h3 = TextStyle(fontSize: 17, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.text);
  static const body = TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.text);
  static const bodyStrong = TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.text);
  static const caption = TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const label = TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const tiny = TextStyle(fontSize: 11, height: 1.3, fontWeight: FontWeight.w500, color: AppColors.textMuted);
}
