import { useMemo, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { SearchInput } from '@/components/SearchInput';
import { Card } from '@/components/Card';
import { StatusBadge } from '@/components/StatusBadge';
import { LoadingState } from '@/components/LoadingState';
import { ErrorState } from '@/components/ErrorState';
import { EmptyState } from '@/components/EmptyState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { colors, spacing, typography } from '@/theme';
import type { TenantStatus } from '@servis/shared';

const STATUS_TONE: Record<TenantStatus, 'success' | 'danger' | 'neutral'> = {
  active: 'success',
  suspended: 'danger',
  passive: 'neutral',
};
const STATUS_LABEL: Record<TenantStatus, string> = {
  active: 'Aktif',
  suspended: 'Askıda',
  passive: 'Pasif',
};

/** Müşteri şirket listesi + arama. */
export default function CustomersScreen() {
  const [search, setSearch] = useState('');
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: queryKeys.tenants,
    queryFn: dataService.listTenants,
  });

  const filtered = useMemo(
    () =>
      (data ?? []).filter(
        (t) =>
          t.name.toLowerCase().includes(search.toLowerCase()) ||
          t.company_code.toLowerCase().includes(search.toLowerCase()),
      ),
    [data, search],
  );

  if (isLoading) return <LoadingState />;
  if (isError) return <ErrorState onRetry={refetch} />;

  return (
    <ScreenContainer refreshing={isLoading} onRefresh={refetch}>
      <AppHeader title="Müşteriler" subtitle={`${data?.length ?? 0} şirket`} right={{ label: '+ Yeni', onPress: () => {} }} />
      <SearchInput value={search} onChangeText={setSearch} placeholder="Şirket adı veya kodu…" />

      {filtered.length === 0 ? (
        <EmptyState title="Şirket bulunamadı" />
      ) : (
        filtered.map((tenant) => (
          <Card key={tenant.id} style={styles.card}>
            <View style={styles.row}>
              <View style={styles.flex}>
                <Text style={typography.h3}>{tenant.name}</Text>
                <Text style={typography.tiny}>{tenant.company_code}</Text>
              </View>
              <StatusBadge kind="custom" label={STATUS_LABEL[tenant.status]} tone={STATUS_TONE[tenant.status]} />
            </View>
            <View style={styles.meta}>
              <Text style={typography.tiny}>
                {tenant.active_user_count}/{tenant.user_limit} kullanıcı
              </Text>
              <Text style={typography.tiny}>{tenant.active_trip_count} aktif servis</Text>
            </View>
          </Card>
        ))
      )}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  card: { gap: spacing.sm },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
  meta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
    paddingTop: spacing.sm,
  },
});
