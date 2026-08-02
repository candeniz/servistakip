import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { ROLE_LABELS } from '@servis/shared';
import { Card } from '@/components/Card';
import { UserAvatar } from '@/components/UserAvatar';
import { PrimaryButton } from '@/components/PrimaryButton';
import { SecondaryButton } from '@/components/SecondaryButton';
import { ConfirmationModal } from '@/components/ConfirmationModal';
import { useAuth } from '@/hooks/useAuth';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

/** Tüm rollerin profil/ayarlar ekranında paylaşılan panel. */
export function ProfilePanel() {
  const { user, logout } = useAuth();
  const [confirming, setConfirming] = useState(false);
  const [loggingOut, setLoggingOut] = useState(false);

  if (!user) return null;

  const onLogout = async () => {
    setLoggingOut(true);
    await logout();
    setLoggingOut(false);
    setConfirming(false);
    router.replace('/(auth)/login');
  };

  return (
    <View style={styles.container}>
      <Card style={styles.header}>
        <UserAvatar name={`${user.first_name} ${user.last_name}`} photoUrl={user.profile_photo} size={64} />
        <View style={styles.flex}>
          <Text style={typography.h2}>
            {user.first_name} {user.last_name}
          </Text>
          <Text style={typography.caption}>{user.email}</Text>
          <Text style={[typography.label, { color: colors.primary }]}>{ROLE_LABELS[user.role]}</Text>
        </View>
      </Card>

      {user.tenant_name ? (
        <Card>
          <Text style={typography.label}>ŞİRKET</Text>
          <Text style={typography.bodyStrong}>{user.tenant_name}</Text>
        </Card>
      ) : null}

      <Card style={styles.actions}>
        <SecondaryButton label="İzinleri Yönet" onPress={() => router.push('/(auth)/permissions')} />
        <PrimaryButton label={strings.auth.logout} variant="danger" onPress={() => setConfirming(true)} />
      </Card>

      <ConfirmationModal
        visible={confirming}
        title="Çıkış yapılsın mı?"
        message="Oturumunuz kapatılacak."
        confirmLabel={strings.auth.logout}
        destructive
        loading={loggingOut}
        onConfirm={onLogout}
        onCancel={() => setConfirming(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { gap: spacing.md },
  header: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg },
  flex: { flex: 1, gap: 2 },
  actions: { gap: spacing.md },
});
