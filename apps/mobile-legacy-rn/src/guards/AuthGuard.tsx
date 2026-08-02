import { ReactNode } from 'react';
import { Redirect } from 'expo-router';
import { useAuthStore } from '@/stores/authStore';
import { LoadingState } from '@/components/LoadingState';

/**
 * Oturum açılmamışsa giriş ekranına yönlendirir.
 * Rol bazlı grup layout'larının kökünde kullanılır.
 */
export function AuthGuard({ children }: { children: ReactNode }) {
  const status = useAuthStore((s) => s.status);
  const hydrated = useAuthStore((s) => s.hydrated);

  if (!hydrated || status === 'idle' || status === 'loading') {
    return <LoadingState message="Oturum kontrol ediliyor…" />;
  }
  if (status === 'unauthenticated') {
    return <Redirect href="/(auth)/login" />;
  }
  return <>{children}</>;
}
