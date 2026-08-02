import { StyleSheet, Text, View } from 'react-native';
import type { Stop } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';

interface StopTimelineProps {
  stops: Stop[];
  /** Sıradaki durağın index'i (araç buraya gidiyor). */
  nextStopIndex: number;
  /** Vurgulanacak durak (ör. yolcunun durağı). */
  highlightStopId?: string;
}

/** Durakların dikey zaman çizelgesi; geçilen/aktif/bekleyen durumları gösterir. */
export function StopTimeline({ stops, nextStopIndex, highlightStopId }: StopTimelineProps) {
  return (
    <View style={styles.container}>
      {stops.map((stop, index) => {
        const passed = index < nextStopIndex;
        const isNext = index === nextStopIndex;
        const isHighlight = stop.id === highlightStopId;
        const dotColor = passed ? colors.success : isNext ? colors.primary : colors.border;
        return (
          <View key={stop.id} style={styles.row}>
            <View style={styles.railColumn}>
              <View style={[styles.dot, { backgroundColor: dotColor }, isNext && styles.dotActive]} />
              {index < stops.length - 1 ? (
                <View style={[styles.line, { backgroundColor: passed ? colors.success : colors.border }]} />
              ) : null}
            </View>
            <View style={styles.content}>
              <Text
                style={[
                  typography.bodyStrong,
                  isHighlight && { color: colors.primary },
                  passed && { color: colors.textMuted },
                ]}
              >
                {stop.name}
                {isHighlight ? '  •  Durağınız' : ''}
              </Text>
              <Text style={typography.tiny}>
                {isNext ? 'Sıradaki durak' : passed ? 'Geçildi' : `+${stop.planned_arrival_offset} dk`}
              </Text>
            </View>
          </View>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { gap: 0 },
  row: { flexDirection: 'row', gap: spacing.md },
  railColumn: { alignItems: 'center', width: 20 },
  dot: { width: 12, height: 12, borderRadius: 6, marginTop: 4 },
  dotActive: { width: 16, height: 16, borderRadius: 8, marginTop: 2, borderWidth: 3, borderColor: colors.primaryLight },
  line: { width: 2, flex: 1, minHeight: 26, marginVertical: 2 },
  content: { flex: 1, paddingBottom: spacing.lg, gap: 2 },
});
