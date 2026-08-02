import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { ProfilePanel } from '@/features/ProfilePanel';

/** Süper Admin ayarlar/profil. */
export default function SettingsScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Ayarlar" />
      <ProfilePanel />
    </ScreenContainer>
  );
}
