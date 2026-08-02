import { useAuthStore } from '@/stores/authStore';

/** Oturum bilgisine kısa erişim sağlayan yardımcı hook. */
export function useAuth() {
  const user = useAuthStore((s) => s.user);
  const status = useAuthStore((s) => s.status);
  const login = useAuthStore((s) => s.login);
  const logout = useAuthStore((s) => s.logout);
  const error = useAuthStore((s) => s.error);
  const clearError = useAuthStore((s) => s.clearError);

  return {
    user,
    status,
    isAuthenticated: status === 'authenticated',
    login,
    logout,
    error,
    clearError,
  };
}
