import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { ProfilePanel } from '@/features/ProfilePanel';

/** Yolcu profili. */
export default function PassengerProfileScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Profil" />
      <ProfilePanel />
    </ScreenContainer>
  );
}
