import { useQuery } from '@tanstack/react-query';
import { NotificationCard } from '@/components/NotificationCard';
import { LoadingState } from '@/components/LoadingState';
import { ErrorState } from '@/components/ErrorState';
import { EmptyState } from '@/components/EmptyState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';

/** Bildirim listesini yükleyip gösteren paylaşılan bileşen (şoför/yolcu). */
export function NotificationsList() {
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: queryKeys.notifications,
    queryFn: dataService.listNotifications,
  });

  if (isLoading) return <LoadingState />;
  if (isError) return <ErrorState onRetry={refetch} />;
  if (!data || data.length === 0) return <EmptyState title="Bildirim yok" icon="🔔" />;

  return (
    <>
      {data.map((n) => (
        <NotificationCard key={n.id} notification={n} />
      ))}
    </>
  );
}
