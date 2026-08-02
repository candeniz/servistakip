import 'package:flutter/material.dart';

/// Renk token'ları. Marka rengi tenant.primaryColor ile ezilebilir.
class AppColors {
  const AppColors._();

  // Marka
  static const primary = Color(0xFF1E5EFF);
  static const primaryDark = Color(0xFF1746C0);
  static const primaryLight = Color(0xFFE8F0FF);

  // Yüzey / arka plan
  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F2F7);
  static const border = Color(0xFFE2E6EF);

  // Metin
  static const text = Color(0xFF0F1B2D);
  static const textSecondary = Color(0xFF5A6B85);
  static const textMuted = Color(0xFF93A0B5);
  static const textInverse = Color(0xFFFFFFFF);

  // Durumlar
  static const success = Color(0xFF1DAA6D);
  static const successBg = Color(0xFFE4F7EE);
  static const warning = Color(0xFFF2A007);
  static const warningBg = Color(0xFFFEF3DD);
  static const danger = Color(0xFFE5484D);
  static const dangerBg = Color(0xFFFCE9EA);
  static const info = Color(0xFF0B7FD4);
  static const infoBg = Color(0xFFE1F1FC);

  // Servis durum renkleri
  static const statusPaused = Color(0xFF7A5AF8);

  static const overlay = Color(0x730F1B2D);
}
