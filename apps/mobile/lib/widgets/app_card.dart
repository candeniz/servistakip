import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Ortak yüzey kartı — Stitch: 20px yuvarlak köşe, yumuşak mavi kenarlık, hafif gölge.
/// [accentColor] verilirse sol kenarda vurgu şeridi çizilir (istatistik kartları).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.accentColor,
    this.radius = 20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? accentColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0B1C30), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );

    // Sol vurgu şeridi
    if (accentColor != null) {
      content = Container(
        decoration: BoxDecoration(borderRadius: borderRadius, color: accentColor),
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius - 2),
              bottomLeft: Radius.circular(radius - 2),
              topRight: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            border: Border.all(color: AppColors.border),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      );
    }

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
    );
  }
}
