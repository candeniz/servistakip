import { StyleSheet, Text, View } from 'react-native';
import {
  TRIP_STATUS_LABELS,
  BOARDING_STATUS_LABELS,
  type TripStatus,
  type BoardingStatus,
} from '@servis/shared';
import { borderRadius, colors, spacing, typography } from '@/theme';

const TRIP_COLORS: Record<TripStatus, { bg: string; fg: string }> = {
  scheduled: { bg: colors.surfaceAlt, fg: colors.statusScheduled },
  preparing: { bg: colors.infoBg, fg: colors.statusPreparing },
  active: { bg: colors.successBg, fg: colors.statusActive },
  delayed: { bg: colors.warningBg, fg: colors.statusDelayed },
  paused: { bg: '#EEEAFF', fg: colors.statusPaused },
  completed: { bg: colors.surfaceAlt, fg: colors.statusCompleted },
  cancelled: { bg: colors.dangerBg, fg: colors.statusCancelled },
};

const BOARDING_COLORS: Record<BoardingStatus, { bg: string; fg: string }> = {
  expected: { bg: colors.surfaceAlt, fg: colors.textSecondary },
  boarded: { bg: colors.successBg, fg: colors.success },
  no_show: { bg: colors.dangerBg, fg: colors.danger },
  absent: { bg: colors.warningBg, fg: colors.warning },
  wrong_stop: { bg: colors.infoBg, fg: colors.info },
  cancelled: { bg: colors.surfaceAlt, fg: colors.textMuted },
};

type Props =
  | { kind: 'trip'; value: TripStatus }
  | { kind: 'boarding'; value: BoardingStatus }
  | { kind: 'custom'; label: string; tone: 'success' | 'warning' | 'danger' | 'info' | 'neutral' };

/** Durum rozeti — servis, biniş veya özel durum. */
export function StatusBadge(props: Props) {
  let bg: string;
  let fg: string;
  let label: string;

  if (props.kind === 'trip') {
    ({ bg, fg } = TRIP_COLORS[props.value]);
    label = TRIP_STATUS_LABELS[props.value];
  } else if (props.kind === 'boarding') {
    ({ bg, fg } = BOARDING_COLORS[props.value]);
    label = BOARDING_STATUS_LABELS[props.value];
  } else {
    const tones = {
      success: { bg: colors.successBg, fg: colors.success },
      warning: { bg: colors.warningBg, fg: colors.warning },
      danger: { bg: colors.dangerBg, fg: colors.danger },
      info: { bg: colors.infoBg, fg: colors.info },
      neutral: { bg: colors.surfaceAlt, fg: colors.textSecondary },
    } as const;
    ({ bg, fg } = tones[props.tone]);
    label = props.label;
  }

  return (
    <View style={[styles.badge, { backgroundColor: bg }]}>
      <Text style={[styles.label, { color: fg }]}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    paddingHorizontal: spacing.sm,
    paddingVertical: 3,
    borderRadius: borderRadius.pill,
    alignSelf: 'flex-start',
  },
  label: { ...typography.label, fontWeight: '700' },
});
