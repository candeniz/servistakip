import { StyleSheet, Text, View } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { StatCard } from '@/components/StatCard';
import { ServiceCard } from '@/components/ServiceCard';
import { LoadingState } from '@/components/LoadingState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { spacing, typography } from '@/theme';

/** Platform geneli canlı operasyon özeti. */
export default function LiveOperationsScreen() {
  const { data: trips, isLoading, refetch } = useQuery({
    queryKey: queryKeys.trips(),
    queryFn: dataService.listTrips,
  });

  if (isLoading) return <LoadingState />;
  const active = (trips ?? []).filter((t) => t.status === 'active' || t.status === 'delayed');

  return (
    <ScreenContainer refreshing={isLoading} onRefresh={refetch}>
      <AppHeader title="Canlı Operasyon" subtitle="Tüm şirketlerde yolda olan servisler" />
      <View style={styles.grid}>
        <StatCard label="Yolda" value={active.length} tone="success" />
        <StatCard label="Gecikmeli" value={active.filter((t) => t.delay_minutes > 0).length} tone="warning" />
      </View>
      <Text style={typography.label}>AKTİF SERVİSLER</Text>
      {active.map((trip) => (
        <ServiceCard key={trip.id} trip={trip} />
      ))}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', gap: spacing.md },
});
