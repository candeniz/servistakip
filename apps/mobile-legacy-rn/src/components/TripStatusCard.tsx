import { StyleSheet, Text, View } from 'react-native';
import type { ServiceTrip } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';
import { StatusBadge } from './StatusBadge';
import { formatTime } from '@/lib/format';

/** Aktif servisin özet başlık kartı (şoför/yönetici). */
export function TripStatusCard({ trip }: { trip: ServiceTrip }) {
  return (
    <Card style={styles.card}>
      <View style={styles.row}>
        <Text style={typography.h2} numberOfLines={1}>
          {trip.service_name}
        </Text>
        <StatusBadge kind="trip" value={trip.status} />
      </View>
      <Text style={typography.caption}>{trip.route_name}</Text>
      <View style={styles.grid}>
        <Info label="Plaka" value={trip.vehicle_plate} />
        <Info label="Başlangıç" value={formatTime(trip.actual_start_at ?? trip.planned_start_at)} />
        <Info
          label="Gecikme"
          value={trip.delay_minutes > 0 ? `${trip.delay_minutes} dk` : 'Yok'}
          tone={trip.delay_minutes > 0 ? colors.warning : colors.success}
        />
      </View>
    </Card>
  );
}

function Info({ label, value, tone }: { label: string; value: string; tone?: string }) {
  return (
    <View style={styles.info}>
      <Text style={typography.tiny}>{label}</Text>
      <Text style={[typography.bodyStrong, tone ? { color: tone } : null]}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: { gap: spacing.sm },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: spacing.sm },
  grid: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.xs },
  info: { flex: 1, gap: 2 },
});
