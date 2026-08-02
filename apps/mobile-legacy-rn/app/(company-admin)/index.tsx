import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { StatCard } from '@/components/StatCard';
import { ServiceCard } from '@/components/ServiceCard';
import { LoadingState } from '@/components/LoadingState';
import { ErrorState } from '@/components/ErrorState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { useAuth } from '@/hooks/useAuth';
import { spacing, typography } from '@/theme';

/** Yönetici ana sayfası: şirket özeti + bugünkü servisler. */
export default function AdminHome() {
  const { user } = useAuth();
  const { data: trips, isLoading, isError, refetch } = useQuery({
    queryKey: queryKeys.trips(),
    queryFn: dataService.listTrips,
  });

  if (isLoading) return <LoadingState />;
  if (isError || !trips) return <ErrorState onRetry={refetch} />;

  const active = trips.filter((t) => t.status === 'active' || t.status === 'delayed').length;
  const passengers = trips.reduce((s, t) => s + t.passenger_count, 0);

  return (
    <ScreenContainer refreshing={isLoading} onRefresh={refetch}>
      <AppHeader title={`Merhaba, ${user?.first_name ?? ''}`} subtitle={user?.tenant_name ?? undefined} />
      <View style={styles.grid}>
        <StatCard label="Bugünkü Servis" value={trips.length} />
        <StatCard label="Yolda" value={active} tone="success" />
        <StatCard label="Toplam Yolcu" value={passengers} />
        <StatCard label="Aktif Araç" value={active} />
      </View>

      <View style={styles.sectionHeader}>
        <Text style={typography.label}>BUGÜNKÜ SERVİSLER</Text>
        <Text style={typography.tiny} onPress={() => router.push('/(company-admin)/services')}>
          Tümü →
        </Text>
      </View>
      {trips.map((trip) => (
        <ServiceCard
          key={trip.id}
          trip={trip}
          onPress={() => router.push(`/(company-admin)/trip/${trip.id}` as never)}
        />
      ))}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.md },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: spacing.sm },
});
