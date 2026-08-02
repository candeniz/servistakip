import { useMemo } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { PassengerRow } from '@/components/PassengerRow';
import { StatCard } from '@/components/StatCard';
import { useSimulationStore } from '@/stores/simulationStore';
import { demoStops } from '@/mocks/demoData';
import { spacing, typography } from '@/theme';

/** Şoför yolcu listesi: durak bazında biniş durumu işaretleme. */
export default function DriverPassengersScreen() {
  const { passengers, setPassengerStatus, nextStopIndex } = useSimulationStore();

  const boarded = passengers.filter((p) => p.boarding_status === 'boarded').length;
  const stopIndexById = useMemo(() => new Map(demoStops.map((s, i) => [s.id, i])), []);

  // Duraklara göre grupla (sıralı).
  const grouped = useMemo(() => {
    return demoStops.map((stop, index) => ({
      stop,
      index,
      passengers: passengers.filter((p) => p.stop_id === stop.id),
    }));
  }, [passengers]);

  return (
    <ScreenContainer>
      <AppHeader title="Yolcular" subtitle={`${boarded}/${passengers.length} bindi`} />
      <View style={styles.grid}>
        <StatCard label="Toplam" value={passengers.length} />
        <StatCard label="Bindi" value={boarded} tone="success" />
        <StatCard label="Kalan" value={passengers.length - boarded} />
      </View>

      {grouped.map(({ stop, index, passengers: stopPassengers }) => {
        if (stopPassengers.length === 0) return null;
        const isNext = index === nextStopIndex;
        return (
          <View key={stop.id} style={styles.group}>
            <Text style={[typography.label, isNext && { color: '#1E5EFF' }]}>
              {stop.name.toUpperCase()} {isNext ? '• SIRADAKİ' : ''}
            </Text>
            {stopPassengers.map((p) => (
              <PassengerRow
                key={p.id}
                passenger={p}
                onSetStatus={(status) => setPassengerStatus(p.id, status)}
              />
            ))}
          </View>
        );
      })}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', gap: spacing.md },
  group: { gap: spacing.sm },
});
