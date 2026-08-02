import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { LiveMap } from '@/components/LiveMap';
import { ETAWidget } from '@/components/ETAWidget';
import { RemainingStopsCard } from '@/components/RemainingStopsCard';
import { Card } from '@/components/Card';
import { UserAvatar } from '@/components/UserAvatar';
import { SecondaryButton } from '@/components/SecondaryButton';
import { OfflineBanner } from '@/components/OfflineBanner';
import { LoadingState } from '@/components/LoadingState';
import { useLiveTrip } from '@/hooks/useLiveTrip';
import { demoStops, demoSimulationPath, demoPassengerSnapshot } from '@/mocks/demoData';
import { spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

/** Yolcu canlı servis ana ekranı: harita + ETA + kalan durak + şoför bilgisi. */
export default function PassengerHome() {
  const { location, heading, eta, nextStop, targetStop, finished, trip } = useLiveTrip();

  if (!location || !eta) {
    return <LoadingState message="Servis konumu alınıyor…" />;
  }

  return (
    <ScreenContainer>
      <OfflineBanner
        visible={eta.delay_minutes > 0}
        message={`Servis ${eta.delay_minutes} dk gecikmeli`}
        tone="warning"
      />
      {finished ? (
        <OfflineBanner visible message="Servis durağınıza ulaştı 🎉" tone="warning" />
      ) : null}

      <AppHeader title={strings.passenger.liveTitle} subtitle={trip.service_name} />

      <ETAWidget eta={eta} />

      <RemainingStopsCard
        remainingStops={eta.remaining_stops}
        passengerStopName={targetStop?.name ?? demoPassengerSnapshot.passengerStopName}
        nextStopName={nextStop?.name ?? '—'}
      />

      <LiveMap
        vehicleLocation={location}
        vehicleHeading={heading}
        vehiclePlate={trip.vehicle_plate}
        stops={demoStops}
        routePath={demoSimulationPath}
        highlightStopId={targetStop?.id}
        height={260}
      />

      <Text style={typography.label}>{strings.passenger.driverInfo.toUpperCase()}</Text>
      <Card style={styles.driverRow}>
        <UserAvatar name={trip.driver_name} size={44} />
        <View style={styles.flex}>
          <Text style={typography.bodyStrong}>{trip.driver_name}</Text>
          <Text style={typography.caption}>
            {trip.vehicle_plate} · {demoStops.length} durak
          </Text>
        </View>
      </Card>

      <SecondaryButton
        label={strings.passenger.absentToday}
        onPress={() => router.push('/(passenger)/my-service')}
      />
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  driverRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
