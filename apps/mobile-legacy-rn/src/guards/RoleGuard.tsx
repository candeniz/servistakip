import { ReactNode } from 'react';
import { Redirect } from 'expo-router';
import { ROLE_HOME_SEGMENT, type Role } from '@servis/shared';
import { useAuthStore } from '@/stores/authStore';
import { ErrorState } from '@/components/ErrorState';
import { strings } from '@/constants/strings';

interface RoleGuardProps {
  allow: Role[];
  children: ReactNode;
  /** true ise yetkisiz kullanıcı kendi ana ekranına yönlendirilir. */
  redirectToHome?: boolean;
}

/**
 * Kullanıcının rolü izin listesinde değilse erişimi engeller.
 * NOT: Bu yalnızca UX içindir; asıl yetki kontrolü backend'de yapılır.
 */
export function RoleGuard({ allow, children, redirectToHome = true }: RoleGuardProps) {
  const user = useAuthStore((s) => s.user);
  if (!user) return <Redirect href="/(auth)/login" />;

  if (!allow.includes(user.role)) {
    if (redirectToHome) {
      const segment = ROLE_HOME_SEGMENT[user.role];
      return <Redirect href={`/${segment}` as never} />;
    }
    return <ErrorState title={strings.errors.unauthorized} />;
  }
  return <>{children}</>;
}
