import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { ProfilePanel } from '@/features/ProfilePanel';

/** Şoför profili. */
export default function DriverProfileScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Profil" />
      <ProfilePanel />
    </ScreenContainer>
  );
}
