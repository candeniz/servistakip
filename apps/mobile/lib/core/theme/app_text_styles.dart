import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi ölçeği — birincil font **Poppins**.
///
/// Teknik etiketler (mono* getter'ları) Poppins'in büyük-harf + harf aralıklı
/// varyantıyla verilir; böylece tek font ailesiyle "etiket" hissi korunur.
/// Getter'lar const değildir çünkü fontlar GoogleFonts ile runtime'da yüklenir.
class AppText {
  const AppText._();

  static TextStyle _p(double size, FontWeight weight, Color color, {double height = 1.3, double spacing = 0}) =>
      GoogleFonts.poppins(fontSize: size, height: height, fontWeight: weight, color: color, letterSpacing: spacing);

  // ── Başlık + gövde ──
  static TextStyle get display => _p(30, FontWeight.w700, AppColors.text, height: 1.15);
  static TextStyle get h1 => _p(25, FontWeight.w700, AppColors.text, height: 1.2);
  static TextStyle get h2 => _p(20, FontWeight.w600, AppColors.text, height: 1.25);
  static TextStyle get h3 => _p(17, FontWeight.w600, AppColors.text, height: 1.3);
  static TextStyle get body => _p(15, FontWeight.w400, AppColors.text, height: 1.45);
  static TextStyle get bodyStrong => _p(15, FontWeight.w600, AppColors.text, height: 1.4);
  static TextStyle get caption => _p(14, FontWeight.w400, AppColors.textSecondary, height: 1.4);

  /// Büyük istatistik değerleri (ör. "124", "842").
  static TextStyle get statValue => _p(38, FontWeight.w700, AppColors.text, height: 1.05);

  // ── Teknik etiketler (Poppins, büyük-harf + harf aralığı) ──
  static TextStyle get monoLabel => _p(12, FontWeight.w600, AppColors.textSecondary, height: 1.3, spacing: 0.8);
  static TextStyle get monoTiny => _p(11, FontWeight.w500, AppColors.textMuted, height: 1.3, spacing: 0.5);

  /// Buton/plaka gibi vurgulu etiket.
  static TextStyle get monoStrong => _p(14, FontWeight.w600, AppColors.text, height: 1.2, spacing: 0.6);

  // Eski kod uyumu için takma adlar.
  static TextStyle get label => monoLabel;
  static TextStyle get tiny => monoTiny;
}
