import { StyleSheet, Text, View } from 'react-native';
import { useLocalSearchParams, Stack } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TripStatusCard } from '@/components/TripStatusCard';
import { StopTimeline } from '@/components/StopTimeline';
import { PassengerRow } from '@/components/PassengerRow';
import { LoadingState } from '@/components/LoadingState';
import { ErrorState } from '@/components/ErrorState';
import { dataService } from '@/services/dataService';
import { queryKeys } from '@/constants/queryKeys';
import { demoStops } from '@/mocks/demoData';
import { spacing, typography } from '@/theme';
import { NewTripForm } from '@/features/NewTripForm';

/** Servis detayı (yolcular + durak zaman çizelgesi). id=new ise oluşturma formu. */
export default function TripDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  if (id === 'new') {
    return (
      <ScreenContainer>
        <Stack.Screen options={{ headerShown: false }} />
        <AppHeader title="Yeni Servis" subtitle="Servis tanımı oluştur" />
        <NewTripForm />
      </ScreenContainer>
    );
  }

  return <TripDetail id={id} />;
}

function TripDetail({ id }: { id: string }) {
  const tripQuery = useQuery({ queryKey: queryKeys.trip(id), queryFn: () => dataService.getTrip(id) });
  const paxQuery = useQuery({
    queryKey: queryKeys.tripPassengers(id),
    queryFn: () => dataService.listTripPassengers(id),
  });

  if (tripQuery.isLoading || paxQuery.isLoading) return <LoadingState />;
  if (tripQuery.isError || !tripQuery.data) return <ErrorState onRetry={tripQuery.refetch} />;

  const trip = tripQuery.data;
  const passengers = paxQuery.data ?? [];

  return (
    <ScreenContainer>
      <AppHeader title="Servis Detayı" subtitle={trip.route_name} />
      <TripStatusCard trip={trip} />

      <Text style={typography.label}>DURAKLAR</Text>
      <View style={styles.card}>
        <StopTimeline stops={demoStops} nextStopIndex={1} />
      </View>

      <Text style={typography.label}>YOLCULAR ({passengers.length})</Text>
      {passengers.map((p) => (
        <PassengerRow key={p.id} passenger={p} />
      ))}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  card: { marginBottom: spacing.sm },
});
