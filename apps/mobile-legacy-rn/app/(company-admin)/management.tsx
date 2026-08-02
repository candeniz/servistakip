import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { Card } from '@/components/Card';
import { VehicleCard } from '@/components/VehicleCard';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { ProfilePanel } from '@/features/ProfilePanel';
import { colors, spacing, typography } from '@/theme';

/** Yönetim: araçlar, güzergâhlar, duyuru ve profil. */
export default function ManagementScreen() {
  const { data: vehicles } = useQuery({ queryKey: queryKeys.vehicles, queryFn: dataService.listVehicles });
  const { data: route } = useQuery({
    queryKey: queryKeys.route('route-avrupa-sabah'),
    queryFn: () => dataService.getRoute('route-avrupa-sabah'),
  });

  return (
    <ScreenContainer>
      <AppHeader title="Yönetim" />

      <MenuItem icon="📣" label="Duyuru Oluştur" onPress={() => router.push('/(company-admin)/announcement')} />

      <Text style={typography.label}>ARAÇLAR ({vehicles?.length ?? 0})</Text>
      {(vehicles ?? []).map((v) => (
        <VehicleCard key={v.id} vehicle={v} />
      ))}

      <Text style={typography.label}>GÜZERGÂHLAR</Text>
      {route ? (
        <Card>
          <Text style={typography.h3}>{route.name}</Text>
          <Text style={typography.caption}>
            {route.start_location} → {route.end_location} · {route.stop_count} durak
          </Text>
        </Card>
      ) : null}

      <View style={styles.divider} />
      <ProfilePanel />
    </ScreenContainer>
  );
}

function MenuItem({ icon, label, onPress }: { icon: string; label: string; onPress: () => void }) {
  return (
    <Card onPress={onPress} style={styles.menuItem}>
      <Text style={styles.icon}>{icon}</Text>
      <Text style={[typography.bodyStrong, styles.flex]}>{label}</Text>
      <Text style={{ color: colors.textMuted }}>›</Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  menuItem: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  icon: { fontSize: 22 },
  flex: { flex: 1 },
  divider: { height: StyleSheet.hairlineWidth, backgroundColor: colors.border, marginVertical: spacing.sm },
});
