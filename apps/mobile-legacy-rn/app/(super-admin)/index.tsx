import { StyleSheet, View } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { StatCard } from '@/components/StatCard';
import { LoadingState } from '@/components/LoadingState';
import { ErrorState } from '@/components/ErrorState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { spacing, typography } from '@/theme';
import { Text } from 'react-native';

/** Süper Admin genel bakış: platform geneli istatistikler. */
export default function SuperAdminDashboard() {
  const { data: tenants, isLoading, isError, refetch } = useQuery({
    queryKey: queryKeys.tenants,
    queryFn: dataService.listTenants,
  });

  if (isLoading) return <LoadingState />;
  if (isError || !tenants) return <ErrorState onRetry={refetch} />;

  const activeTenants = tenants.filter((t) => t.status === 'active').length;
  const totalUsers = tenants.reduce((sum, t) => sum + t.active_user_count, 0);
  const activeTrips = tenants.reduce((sum, t) => sum + t.active_trip_count, 0);

  return (
    <ScreenContainer refreshing={isLoading} onRefresh={refetch}>
      <AppHeader title="Platform Paneli" subtitle="Genel operasyon durumu" />
      <View style={styles.grid}>
        <StatCard label="Toplam Şirket" value={tenants.length} />
        <StatCard label="Aktif Şirket" value={activeTenants} tone="success" />
        <StatCard label="Toplam Kullanıcı" value={totalUsers} />
        <StatCard label="Aktif Servis" value={activeTrips} tone="success" hint="Şu an yolda" />
      </View>
      <Text style={[typography.caption, styles.note]}>
        Aşağıda müşteri şirketlerin özetini görebilir, Müşteriler sekmesinden yönetebilirsiniz.
      </Text>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.md },
  note: { marginTop: spacing.sm },
});
