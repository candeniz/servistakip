import { StyleSheet, Text, View } from 'react-native';
import type { ServiceTrip } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';
import { StatusBadge } from './StatusBadge';
import { formatTime } from '@/lib/format';

/** Servis/yolculuk özet kartı (listelerde kullanılır). */
export function ServiceCard({ trip, onPress }: { trip: ServiceTrip; onPress?: () => void }) {
  return (
    <Card onPress={onPress} style={styles.card}>
      <View style={styles.headerRow}>
        <Text style={typography.h3} numberOfLines={1}>
          {trip.service_name}
        </Text>
        <StatusBadge kind="trip" value={trip.status} />
      </View>
      <Text style={typography.caption}>
        {trip.route_name} · {trip.direction === 'morning' ? 'Sabah' : 'Akşam'}
      </Text>
      <View style={styles.metaRow}>
        <Meta label="Araç" value={trip.vehicle_plate} />
        <Meta label="Şoför" value={trip.driver_name} />
        <Meta label="Kalkış" value={formatTime(trip.planned_start_at)} />
      </View>
      <View style={styles.footerRow}>
        <Text style={typography.tiny}>
          {trip.passenger_count} yolcu · {trip.stop_count} durak
        </Text>
        {trip.delay_minutes > 0 ? (
          <Text style={[typography.tiny, { color: colors.warning }]}>
            {trip.delay_minutes} dk gecikme
          </Text>
        ) : null}
      </View>
    </Card>
  );
}

function Meta({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.meta}>
      <Text style={typography.tiny}>{label}</Text>
      <Text style={typography.bodyStrong} numberOfLines={1}>
        {value}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { gap: spacing.sm },
  headerRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: spacing.sm },
  metaRow: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.xs },
  meta: { flex: 1, gap: 2 },
  footerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
    paddingTop: spacing.sm,
  },
});
