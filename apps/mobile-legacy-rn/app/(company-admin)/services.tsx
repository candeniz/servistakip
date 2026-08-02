import { useMemo, useState } from 'react';
import { router } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { ServiceCard } from '@/components/ServiceCard';
import { FilterSheet, type FilterOption } from '@/components/FilterSheet';
import { SecondaryButton } from '@/components/SecondaryButton';
import { LoadingState } from '@/components/LoadingState';
import { EmptyState } from '@/components/EmptyState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';

type DirectionFilter = 'all' | 'morning' | 'evening';
const OPTIONS: FilterOption<DirectionFilter>[] = [
  { value: 'all', label: 'Tümü' },
  { value: 'morning', label: 'Sabah' },
  { value: 'evening', label: 'Akşam' },
];

/** Servis listesi + yön filtresi + yeni servis. */
export default function ServicesScreen() {
  const [filter, setFilter] = useState<DirectionFilter>('all');
  const [sheetOpen, setSheetOpen] = useState(false);
  const { data, isLoading, refetch } = useQuery({
    queryKey: queryKeys.trips(),
    queryFn: dataService.listTrips,
  });

  const filtered = useMemo(
    () => (data ?? []).filter((t) => filter === 'all' || t.direction === filter),
    [data, filter],
  );

  if (isLoading) return <LoadingState />;

  return (
    <ScreenContainer refreshing={isLoading} onRefresh={refetch}>
      <AppHeader
        title="Servisler"
        subtitle={`${filtered.length} servis`}
        right={{ label: '+ Yeni', onPress: () => router.push('/(company-admin)/trip/new' as never) }}
      />
      <SecondaryButton
        label={`Filtre: ${OPTIONS.find((o) => o.value === filter)?.label}`}
        onPress={() => setSheetOpen(true)}
      />
      {filtered.length === 0 ? (
        <EmptyState title="Servis bulunamadı" />
      ) : (
        filtered.map((trip) => (
          <ServiceCard
            key={trip.id}
            trip={trip}
            onPress={() => router.push(`/(company-admin)/trip/${trip.id}` as never)}
          />
        ))
      )}

      <FilterSheet
        visible={sheetOpen}
        title="Yöne göre filtrele"
        options={OPTIONS}
        selected={filter}
        onSelect={setFilter}
        onClose={() => setSheetOpen(false)}
      />
    </ScreenContainer>
  );
}
