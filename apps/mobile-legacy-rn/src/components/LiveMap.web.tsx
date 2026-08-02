import { StyleSheet, Text, View } from 'react-native';
import type { LatLng, Stop } from '@servis/shared';
import { borderRadius, colors, spacing, typography } from '@/theme';

export interface LiveMapProps {
  vehicleLocation?: LatLng | null;
  vehicleHeading?: number;
  vehiclePlate?: string;
  stops?: Stop[];
  routePath?: LatLng[];
  highlightStopId?: string;
  height?: number;
}

/**
 * Web fallback: react-native-maps web'de çalışmaz.
 * Konum ve durak özetini metinsel olarak gösterir (geliştirme kolaylığı).
 */
export function LiveMap({ vehicleLocation, vehiclePlate, stops = [], height = 260 }: LiveMapProps) {
  return (
    <View style={[styles.container, { height }]}>
      <Text style={styles.icon}>🗺️</Text>
      <Text style={typography.bodyStrong}>Canlı Harita (web önizleme)</Text>
      <Text style={typography.caption}>
        Harita yalnızca iOS/Android üzerinde görüntülenir.
      </Text>
      {vehicleLocation ? (
        <Text style={typography.tiny}>
          {vehiclePlate ?? 'Araç'} · {vehicleLocation.latitude.toFixed(4)},{' '}
          {vehicleLocation.longitude.toFixed(4)}
        </Text>
      ) : null}
      <Text style={typography.tiny}>{stops.length} durak</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    borderRadius: borderRadius.lg,
    backgroundColor: colors.surfaceAlt,
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.xs,
    borderWidth: 1,
    borderColor: colors.border,
  },
  icon: { fontSize: 32 },
});
