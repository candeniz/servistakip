import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi ölçeği — Stitch tasarımı: Hanken Grotesk (UI) + JetBrains Mono (etiket/plaka).
///
/// Getter'lar (const değil) çünkü fontlar GoogleFonts ile runtime'da yüklenir.
class AppText {
  const AppText._();

  // ── Hanken Grotesk (başlık + gövde) ──
  static TextStyle get display =>
      GoogleFonts.hankenGrotesk(fontSize: 32, height: 1.15, fontWeight: FontWeight.w800, color: AppColors.text);
  static TextStyle get h1 =>
      GoogleFonts.hankenGrotesk(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, color: AppColors.text);
  static TextStyle get h2 =>
      GoogleFonts.hankenGrotesk(fontSize: 21, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get h3 =>
      GoogleFonts.hankenGrotesk(fontSize: 17, height: 1.3, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get body =>
      GoogleFonts.hankenGrotesk(fontSize: 15, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.text);
  static TextStyle get bodyStrong =>
      GoogleFonts.hankenGrotesk(fontSize: 15, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle get caption =>
      GoogleFonts.hankenGrotesk(fontSize: 14, height: 1.4, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  /// Büyük istatistik değerleri (ör. "124", "842").
  static TextStyle get statValue =>
      GoogleFonts.hankenGrotesk(fontSize: 40, height: 1.05, fontWeight: FontWeight.w800, color: AppColors.text);

  // ── JetBrains Mono (etiket / buton / plaka / durum) ──
  /// Küçük büyük-harf mono etiket (BUGÜNKÜ SERVİSLER, PLANLANAN…).
  static TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
      fontSize: 12, height: 1.3, fontWeight: FontWeight.w500, letterSpacing: 0.6, color: AppColors.textSecondary);
  static TextStyle get monoTiny => GoogleFonts.jetBrainsMono(
      fontSize: 11, height: 1.3, fontWeight: FontWeight.w500, letterSpacing: 0.4, color: AppColors.textMuted);

  /// Buton/plaka gibi vurgulu mono yazı.
  static TextStyle get monoStrong => GoogleFonts.jetBrainsMono(
      fontSize: 14, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.text);

  // Eski kod uyumu için takma adlar (mono etiket ailesine yönlendirir).
  static TextStyle get label => monoLabel;
  static TextStyle get tiny => monoTiny;
}
