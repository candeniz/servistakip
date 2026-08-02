import { StyleSheet, Text, View } from 'react-native';
import type { EtaResult } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';
import { formatDistance, formatMinutes, formatTime } from '@/lib/format';
import { strings } from '@/constants/strings';

/** Yolcu ekranında tahmini varış bilgilerini gösteren pano. */
export function ETAWidget({ eta }: { eta: EtaResult }) {
  const delayed = eta.delay_minutes > 0;
  return (
    <Card style={styles.card}>
      <View style={styles.hero}>
        <Text style={styles.etaValue}>{formatMinutes(eta.eta_minutes)}</Text>
        <Text style={[typography.caption, styles.onPrimary]}>{strings.passenger.etaLabel}</Text>
      </View>
      <View style={styles.grid}>
        <Metric label={strings.passenger.remainingStops} value={`${eta.remaining_stops}`} />
        <Metric label={strings.passenger.remainingDistance} value={formatDistance(eta.remaining_distance_meters)} />
        <Metric
          label={strings.passenger.delayLabel}
          value={delayed ? formatMinutes(eta.delay_minutes) : 'Yok'}
          tone={delayed ? colors.warning : colors.success}
        />
      </View>
      <View style={styles.times}>
        <Text style={[typography.tiny, styles.onPrimary]}>
          Planlanan: {formatTime(eta.planned_arrival_at)}
        </Text>
        <Text style={[typography.tiny, styles.onPrimary, delayed && { color: colors.warningBg }]}>
          Güncel: {formatTime(eta.estimated_arrival_at)}
        </Text>
      </View>
    </Card>
  );
}

function Metric({ label, value, tone }: { label: string; value: string; tone?: string }) {
  return (
    <View style={styles.metric}>
      <Text style={[styles.metricValue, tone ? { color: tone } : null]}>{value}</Text>
      <Text style={typography.tiny}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { gap: spacing.md, backgroundColor: colors.primary },
  hero: { alignItems: 'center', gap: 2 },
  etaValue: { ...typography.display, fontSize: 40, lineHeight: 44, color: colors.textInverse },
  grid: {
    flexDirection: 'row',
    backgroundColor: colors.surface,
    borderRadius: 12,
    padding: spacing.md,
  },
  metric: { flex: 1, alignItems: 'center', gap: 2 },
  metricValue: { ...typography.h2, color: colors.text },
  times: { flexDirection: 'row', justifyContent: 'space-between' },
  onPrimary: { color: colors.textInverse, opacity: 0.9 },
});
