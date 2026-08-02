import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { NotificationsList } from '@/features/NotificationsList';

/** Yolcu bildirimleri. */
export default function PassengerNotificationsScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Bildirimler" />
      <NotificationsList />
    </ScreenContainer>
  );
}
