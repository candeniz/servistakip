import { useState } from 'react';
import { StyleSheet, Switch, Text, View } from 'react-native';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TripStatusCard } from '@/components/TripStatusCard';
import { StopTimeline } from '@/components/StopTimeline';
import { Card } from '@/components/Card';
import { PrimaryButton } from '@/components/PrimaryButton';
import { useLiveTrip } from '@/hooks/useLiveTrip';
import { demoStops, demoPassengerSnapshot } from '@/mocks/demoData';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

/** Yolcu servis detayı + durak zaman çizelgesi + "bugün binmeyeceğim". */
export default function MyServiceScreen() {
  const { trip, nextStopIndex } = useLiveTrip();
  const [morning, setMorning] = useState(false);
  const [evening, setEvening] = useState(false);
  const [saved, setSaved] = useState(false);

  const onSave = () => {
    // Mock: POST /passenger/absence çağrısını temsil eder.
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <ScreenContainer>
      <AppHeader title="Servisim" subtitle={trip.route_name} />
      <TripStatusCard trip={trip} />

      <Text style={typography.label}>DURAKLAR</Text>
      <Card>
        <StopTimeline
          stops={demoStops}
          nextStopIndex={nextStopIndex}
          highlightStopId={demoPassengerSnapshot.passengerStopId}
        />
      </Card>

      <Text style={typography.label}>{strings.passenger.absentToday.toUpperCase()}</Text>
      <Card style={styles.absence}>
        <View style={styles.switchRow}>
          <Text style={typography.body}>Sabah servisine binmeyeceğim</Text>
          <Switch value={morning} onValueChange={setMorning} trackColor={{ true: colors.primary }} />
        </View>
        <View style={styles.switchRow}>
          <Text style={typography.body}>Akşam servisine binmeyeceğim</Text>
          <Switch value={evening} onValueChange={setEvening} trackColor={{ true: colors.primary }} />
        </View>
        <PrimaryButton
          label={saved ? 'Kaydedildi ✓' : 'Bildir'}
          onPress={onSave}
          disabled={!morning && !evening}
        />
      </Card>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  absence: { gap: spacing.md },
  switchRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
});
