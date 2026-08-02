import 'package:flutter/material.dart';

/// Renk token'ları — Stitch tasarımından birebir çıkarılmıştır.
/// Marka rengi tenant.primaryColor ile ezilebilir.
class AppColors {
  const AppColors._();

  // Marka / birincil
  static const primary = Color(0xFF0051D5); // link + birincil aksiyon
  static const primaryBright = Color(0xFF316BF3); // açık ton / vurgu
  static const primaryDark = Color(0xFF0B1C30); // koyu CTA (lacivert)
  static const primaryDarker = Color(0xFF04162F);
  static const primaryLight = Color(0xFFE5EEFF); // açık mavi dolgu

  // Yüzey / arka plan
  static const background = Color(0xFFF8F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEAF1FF); // tile/chip dolgusu
  static const surfaceTile = Color(0xFFEFF4FF);
  static const border = Color(0xFFD3E4FE); // yumuşak mavi kenarlık
  static const borderStrong = Color(0xFFB6C7E8);
  static const outline = Color(0xFFC5C6CE);

  // Metin
  static const text = Color(0xFF0B1C30);
  static const textSecondary = Color(0xFF4E5F7C);
  static const textMuted = Color(0xFF75777E);
  static const textInverse = Color(0xFFFFFFFF);

  // Durumlar
  static const success = Color(0xFF1DAA6D);
  static const successBg = Color(0xFFE4F7EE);
  static const warning = Color(0xFF9A6A00); // amber metin
  static const warningBg = Color(0xFFFFDEAB);
  static const danger = Color(0xFFBA1A1A);
  static const dangerStrong = Color(0xFF93000A);
  static const dangerBg = Color(0xFFFFDAD6);
  static const info = Color(0xFF0051D5);
  static const infoBg = Color(0xFFDCE9FF);

  static const statusPaused = Color(0xFF7A5AF8);

  static const overlay = Color(0x730B1C30);
}
