import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { PrimaryButton } from '@/components/PrimaryButton';
import { SecondaryButton } from '@/components/SecondaryButton';
import { Card } from '@/components/Card';
import { spacing, typography } from '@/theme';
import { requestLocationPermissions } from '@/services/locationTracking';
import { requestNotificationPermissions } from '@/services/notifications';

/** Konum ve bildirim izinlerini toplayan onboarding ekranı. */
export default function PermissionsScreen() {
  const [location, setLocation] = useState<boolean | null>(null);
  const [notifications, setNotifications] = useState<boolean | null>(null);

  const askLocation = async () => {
    const res = await requestLocationPermissions();
    setLocation(res.foreground);
  };
  const askNotifications = async () => {
    const granted = await requestNotificationPermissions();
    setNotifications(granted);
  };

  return (
    <ScreenContainer>
      <AppHeader title="İzinler" subtitle="Servis takibi için gerekli izinler" />

      <Card style={styles.item}>
        <Text style={typography.h3}>📍 Konum İzni</Text>
        <Text style={typography.caption}>
          Şoförler için canlı konum paylaşımı ve yolcular için harita gösterimi.
        </Text>
        <SecondaryButton
          label={location ? 'Konum izni verildi ✓' : 'Konum İznini Ver'}
          onPress={askLocation}
        />
      </Card>

      <Card style={styles.item}>
        <Text style={typography.h3}>🔔 Bildirim İzni</Text>
        <Text style={typography.caption}>
          Servis yaklaşınca, geciktiğinde ve duyurular için anlık bildirim.
        </Text>
        <SecondaryButton
          label={notifications ? 'Bildirim izni verildi ✓' : 'Bildirim İznini Ver'}
          onPress={askNotifications}
        />
      </Card>

      <View style={styles.footer}>
        <PrimaryButton label="Devam Et" onPress={() => router.back()} />
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  item: { gap: spacing.sm },
  footer: { marginTop: spacing.md },
});
