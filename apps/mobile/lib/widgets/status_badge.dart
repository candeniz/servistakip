import 'package:flutter/material.dart';

import '../core/constants/statuses.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum BadgeTone { success, warning, danger, info, neutral, paused }

class _ToneColors {
  const _ToneColors(this.bg, this.fg);
  final Color bg;
  final Color fg;
}

_ToneColors _tone(BadgeTone tone) => switch (tone) {
      BadgeTone.success => const _ToneColors(AppColors.successBg, AppColors.success),
      BadgeTone.warning => const _ToneColors(AppColors.warningBg, AppColors.warning),
      BadgeTone.danger => const _ToneColors(AppColors.dangerBg, AppColors.danger),
      BadgeTone.info => const _ToneColors(AppColors.infoBg, AppColors.info),
      BadgeTone.neutral => const _ToneColors(AppColors.surfaceAlt, AppColors.textSecondary),
      BadgeTone.paused => const _ToneColors(Color(0xFFEEEAFF), AppColors.statusPaused),
    };

/// Durum rozeti — servis, biniş veya özel durum.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final BadgeTone tone;

  factory StatusBadge.trip(TripStatus status) {
    final tone = switch (status) {
      TripStatus.active => BadgeTone.success,
      TripStatus.delayed => BadgeTone.warning,
      TripStatus.cancelled => BadgeTone.danger,
      TripStatus.preparing => BadgeTone.info,
      TripStatus.paused => BadgeTone.paused,
      TripStatus.scheduled || TripStatus.completed => BadgeTone.neutral,
    };
    return StatusBadge(label: status.label, tone: tone);
  }

  factory StatusBadge.boarding(BoardingStatus status) {
    final tone = switch (status) {
      BoardingStatus.boarded => BadgeTone.success,
      BoardingStatus.noShow => BadgeTone.danger,
      BoardingStatus.absent => BadgeTone.warning,
      BoardingStatus.wrongStop => BadgeTone.info,
      BoardingStatus.expected || BoardingStatus.cancelled => BadgeTone.neutral,
    };
    return StatusBadge(label: status.label, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    final c = _tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppText.label.copyWith(color: c.fg, fontWeight: FontWeight.w700)),
    );
  }
}
