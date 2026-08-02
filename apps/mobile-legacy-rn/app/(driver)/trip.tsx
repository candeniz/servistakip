import { useEffect, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { LiveMap } from '@/components/LiveMap';
import { Card } from '@/components/Card';
import { PrimaryButton } from '@/components/PrimaryButton';
import { SecondaryButton } from '@/components/SecondaryButton';
import { ConfirmationModal } from '@/components/ConfirmationModal';
import { EmptyState } from '@/components/EmptyState';
import { OfflineBanner } from '@/components/OfflineBanner';
import { useSimulationStore } from '@/stores/simulationStore';
import { demoStops, demoTrip, demoSimulationPath } from '@/mocks/demoData';
import { startForegroundTracking, stopForegroundTracking } from '@/services/locationTracking';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

/** Şoför aktif yolculuk ekranı: harita, durak akışı, tamamla/olay. */
export default function DriverTripScreen() {
  const { running, finished, location, heading, nextStopIndex, atStopIndex, speedKmh, stop } =
    useSimulationStore();
  const [atStop, setAtStop] = useState(false);
  const [completing, setCompleting] = useState(false);

  // Servis aktifken ön planda gerçek konum takibini başlat (mock/native güvenli).
  useEffect(() => {
    if (running) {
      void startForegroundTracking(() => {
        /* prod: WS ile gönder — demo simülasyonu store'u besliyor */
      });
    }
    return () => {
      void stopForegroundTracking();
    };
  }, [running]);

  if (!running && !finished) {
    return (
      <ScreenContainer>
        <AppHeader title="Aktif Yolculuk" />
        <EmptyState
          icon="🚦"
          title={strings.errors.tripNotStarted}
          description="Ana sayfadan servis öncesi kontrolü tamamlayıp servisi başlatın."
        />
        <PrimaryButton label="Ana Sayfaya Dön" onPress={() => router.replace('/(driver)')} />
      </ScreenContainer>
    );
  }

  const nextStop = demoStops[nextStopIndex];
  const onComplete = () => {
    stop();
    setCompleting(false);
    router.replace('/(driver)');
  };

  return (
    <ScreenContainer>
      <OfflineBanner visible={finished} message="Servis tamamlanmak üzere — son durağa ulaşıldı." tone="warning" />
      <AppHeader title={demoTrip.service_name} subtitle={`${Math.round(speedKmh)} km/s`} />

      <LiveMap
        vehicleLocation={location}
        vehicleHeading={heading}
        vehiclePlate={demoTrip.vehicle_plate}
        stops={demoStops}
        routePath={demoSimulationPath}
        height={280}
      />

      <Card style={styles.stopCard}>
        <Text style={typography.label}>{strings.driver.nextStop.toUpperCase()}</Text>
        <Text style={typography.h2}>{nextStop?.name ?? 'Son durak'}</Text>
        <Text style={typography.caption}>
          {atStopIndex !== null ? 'Araç durak yarıçapında' : 'Durağa yaklaşılıyor'}
        </Text>
      </Card>

      <View style={styles.actions}>
        {!atStop ? (
          <PrimaryButton label={strings.driver.arrive} onPress={() => setAtStop(true)} />
        ) : (
          <PrimaryButton label={strings.driver.depart} variant="success" onPress={() => setAtStop(false)} />
        )}
        <SecondaryButton label={strings.driver.reportIncident} onPress={() => router.push('/(driver)/incident')} />
      </View>

      <PrimaryButton label={strings.driver.complete} variant="danger" onPress={() => setCompleting(true)} />

      <ConfirmationModal
        visible={completing}
        title="Servis tamamlansın mı?"
        message="Konum paylaşımı duracak ve yolculuk kapatılacak."
        confirmLabel={strings.driver.complete}
        destructive
        onConfirm={onComplete}
        onCancel={() => setCompleting(false)}
      />
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  stopCard: { gap: spacing.xs, borderLeftWidth: 4, borderLeftColor: colors.primary },
  actions: { gap: spacing.md },
});
