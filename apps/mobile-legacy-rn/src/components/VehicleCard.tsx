import { StyleSheet, Text, View } from 'react-native';
import type { Vehicle } from '@servis/shared';
import { spacing, typography } from '@/theme';
import { Card } from './Card';
import { StatusBadge } from './StatusBadge';

const VEHICLE_TONE = {
  active: 'success',
  maintenance: 'warning',
  passive: 'neutral',
} as const;

/** Araç özet kartı. */
export function VehicleCard({ vehicle, onPress }: { vehicle: Vehicle; onPress?: () => void }) {
  return (
    <Card onPress={onPress}>
      <View style={styles.row}>
        <View style={styles.flex}>
          <Text style={typography.h3}>{vehicle.plate_number}</Text>
          <Text style={typography.caption}>
            {vehicle.brand} {vehicle.model} · {vehicle.capacity} kişilik
          </Text>
        </View>
        <StatusBadge
          kind="custom"
          label={vehicle.status === 'active' ? 'Aktif' : vehicle.status === 'maintenance' ? 'Bakımda' : 'Pasif'}
          tone={VEHICLE_TONE[vehicle.status]}
        />
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
