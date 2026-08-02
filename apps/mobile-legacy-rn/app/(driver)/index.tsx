import { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { router } from 'expo-router';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TripStatusCard } from '@/components/TripStatusCard';
import { Card } from '@/components/Card';
import { PrimaryButton } from '@/components/PrimaryButton';
import { ConfirmationModal } from '@/components/ConfirmationModal';
import { useSimulationStore } from '@/stores/simulationStore';
import { demoTrip } from '@/mocks/demoData';
import { useAuth } from '@/hooks/useAuth';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

// Servis öncesi kontrol listesi maddeleri.
const CHECKLIST = [
  'Araç yakıtı yeterli',
  'Lastik ve fren kontrolü yapıldı',
  'İlk yardım çantası mevcut',
  'Yolcu listesi güncel',
];

/** Şoför ana sayfası: bugünkü servis + servis öncesi kontrol + başlat. */
export default function DriverHome() {
  const { user } = useAuth();
  const { running, start } = useSimulationStore();
  const [checked, setChecked] = useState<boolean[]>(CHECKLIST.map(() => false));
  const [confirming, setConfirming] = useState(false);

  const allChecked = checked.every(Boolean);
  const toggle = (i: number) =>
    setChecked((prev) => prev.map((c, idx) => (idx === i ? !c : c)));

  const onStart = () => {
    start();
    setConfirming(false);
    router.push('/(driver)/trip');
  };

  return (
    <ScreenContainer>
      <AppHeader title={`Merhaba, ${user?.first_name ?? ''}`} subtitle="Bugünkü servisiniz" />
      <TripStatusCard trip={demoTrip} />

      <Text style={typography.label}>{strings.driver.preTripCheck.toUpperCase()}</Text>
      <Card style={styles.checklist}>
        {CHECKLIST.map((item, i) => (
          <TouchableOpacity key={item} style={styles.checkRow} onPress={() => toggle(i)}>
            <View style={[styles.checkbox, checked[i] && styles.checkboxOn]}>
              {checked[i] ? <Text style={styles.checkMark}>✓</Text> : null}
            </View>
            <Text style={typography.body}>{item}</Text>
          </TouchableOpacity>
        ))}
      </Card>

      {running ? (
        <PrimaryButton label="Aktif Yolculuğa Git" variant="success" onPress={() => router.push('/(driver)/trip')} />
      ) : (
        <PrimaryButton
          label={strings.driver.start}
          onPress={() => setConfirming(true)}
          disabled={!allChecked}
        />
      )}
      {!allChecked && !running ? (
        <Text style={typography.tiny}>Servisi başlatmak için tüm kontrolleri tamamlayın.</Text>
      ) : null}

      <ConfirmationModal
        visible={confirming}
        title="Servis başlatılsın mı?"
        message="Konum paylaşımı başlayacak ve yolcular bilgilendirilecek."
        confirmLabel={strings.driver.start}
        onConfirm={onStart}
        onCancel={() => setConfirming(false)}
      />
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  checklist: { gap: spacing.sm },
  checkRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, paddingVertical: spacing.xs },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxOn: { backgroundColor: colors.success, borderColor: colors.success },
  checkMark: { color: colors.textInverse, fontWeight: '700', fontSize: 14 },
});
