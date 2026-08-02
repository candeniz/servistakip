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

BadgeTone _tripTone(TripStatus status) => switch (status) {
      TripStatus.active => BadgeTone.info,
      TripStatus.delayed => BadgeTone.warning,
      TripStatus.cancelled => BadgeTone.danger,
      TripStatus.preparing => BadgeTone.info,
      TripStatus.paused => BadgeTone.paused,
      TripStatus.scheduled || TripStatus.completed => BadgeTone.neutral,
    };

BadgeTone _boardingTone(BoardingStatus status) => switch (status) {
      BoardingStatus.boarded => BadgeTone.success,
      BoardingStatus.noShow => BadgeTone.danger,
      BoardingStatus.absent => BadgeTone.warning,
      BoardingStatus.wrongStop => BadgeTone.info,
      BoardingStatus.expected || BoardingStatus.cancelled => BadgeTone.neutral,
    };

/// Dolgulu durum rozeti (pill) — mono, büyük harf.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final BadgeTone tone;

  factory StatusBadge.trip(TripStatus status) => StatusBadge(label: status.label, tone: _tripTone(status));
  factory StatusBadge.boarding(BoardingStatus status) =>
      StatusBadge(label: status.label, tone: _boardingTone(status));

  @override
  Widget build(BuildContext context) {
    final c = _tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label.toUpperCase(),
          style: AppText.monoTiny.copyWith(color: c.fg, fontWeight: FontWeight.w700)),
    );
  }
}

/// Renkli nokta + mono büyük-harf metin (tablo/list durum göstergesi: YOLDA, VARDI…).
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.label, required this.tone});
  final String label;
  final BadgeTone tone;

  factory StatusDot.trip(TripStatus status) => StatusDot(label: status.label, tone: _tripTone(status));

  @override
  Widget build(BuildContext context) {
    final c = _tone(tone);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: AppText.monoTiny.copyWith(color: c.fg, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
