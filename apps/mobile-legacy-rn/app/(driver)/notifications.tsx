import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { NotificationsList } from '@/features/NotificationsList';

/** Şoför bildirimleri. */
export default function DriverNotificationsScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Bildirimler" />
      <NotificationsList />
    </ScreenContainer>
  );
}
