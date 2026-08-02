import { Redirect } from 'expo-router';
import { ROLE_HOME_SEGMENT } from '@servis/shared';
import { useAuthStore } from '@/stores/authStore';
import { LoadingState } from '@/components/LoadingState';

/**
 * Giriş noktası (Splash görevi).
 * Oturum durumuna göre rolün ana ekranına ya da giriş ekranına yönlendirir.
 */
export default function Index() {
  const hydrated = useAuthStore((s) => s.hydrated);
  const user = useAuthStore((s) => s.user);

  if (!hydrated) {
    return <LoadingState message="Başlatılıyor…" />;
  }
  if (!user) {
    return <Redirect href="/(auth)/login" />;
  }
  return <Redirect href={`/${ROLE_HOME_SEGMENT[user.role]}` as never} />;
}
