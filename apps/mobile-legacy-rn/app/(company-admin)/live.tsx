import { useEffect } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { LiveMap } from '@/components/LiveMap';
import { StatCard } from '@/components/StatCard';
import { StatusBadge } from '@/components/StatusBadge';
import { Card } from '@/components/Card';
import { useSimulationStore } from '@/stores/simulationStore';
import { demoStops, demoTrip, demoSimulationPath } from '@/mocks/demoData';
import { spacing, typography } from '@/theme';
import { formatDistance } from '@/lib/format';

/** Yönetici canlı takip: aracın haritada gerçek zamanlı konumu. */
export default function AdminLiveScreen() {
  const { location, heading, nextStopIndex, running, start, speedKmh } = useSimulationStore();

  useEffect(() => {
    // Ekran açılınca simülasyonu başlat (demo).
    if (!running) start();
  }, [running, start]);

  const nextStop = demoStops[nextStopIndex];

  return (
    <ScreenContainer scroll padded>
      <AppHeader title="Canlı Takip" subtitle={demoTrip.service_name} />
      <LiveMap
        vehicleLocation={location}
        vehicleHeading={heading}
        vehiclePlate={demoTrip.vehicle_plate}
        stops={demoStops}
        routePath={demoSimulationPath}
        height={300}
      />
      <View style={styles.grid}>
        <StatCard label="Hız" value={`${Math.round(speedKmh)} km/s`} />
        <StatCard label="Sıradaki Durak" value={nextStop?.name ?? '—'} />
      </View>
      <Card style={styles.row}>
        <View style={styles.flex}>
          <Text style={typography.bodyStrong}>{demoTrip.driver_name}</Text>
          <Text style={typography.tiny}>{demoTrip.vehicle_plate}</Text>
        </View>
        <StatusBadge kind="trip" value={demoTrip.delay_minutes > 0 ? 'delayed' : 'active'} />
      </Card>
      <Text style={typography.tiny}>Toplam mesafe: {formatDistance(demoTrip.total_distance)}</Text>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', gap: spacing.md },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
