import { create } from 'zustand';
import type { AuthUser, Role } from '@servis/shared';
import { authService } from '@/services/authService';
import { secureStore, STORAGE_KEYS } from '@/lib/secureStore';
import { setOnSessionExpired } from '@/services/apiClient';

interface AuthState {
  user: AuthUser | null;
  status: 'idle' | 'loading' | 'authenticated' | 'unauthenticated';
  error: string | null;
  hydrated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  hydrate: () => Promise<void>;
  clearError: () => void;
  role: () => Role | null;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  status: 'idle',
  error: null,
  hydrated: false,

  clearError: () => set({ error: null }),

  role: () => get().user?.role ?? null,

  login: async (email, password) => {
    set({ status: 'loading', error: null });
    try {
      const { user, tokens } = await authService.login(email, password);
      await secureStore.setItem(STORAGE_KEYS.accessToken, tokens.access_token);
      await secureStore.setItem(STORAGE_KEYS.refreshToken, tokens.refresh_token);
      await secureStore.setItem(STORAGE_KEYS.user, JSON.stringify(user));
      set({ user, status: 'authenticated', error: null });
    } catch (e) {
      const message = e instanceof Error ? e.message : 'Giriş başarısız.';
      set({ status: 'unauthenticated', error: message });
      throw e;
    }
  },

  logout: async () => {
    try {
      await authService.logout();
    } catch {
      // Sunucu hatası olsa da yerel oturumu temizle.
    }
    await secureStore.removeItem(STORAGE_KEYS.accessToken);
    await secureStore.removeItem(STORAGE_KEYS.refreshToken);
    await secureStore.removeItem(STORAGE_KEYS.user);
    set({ user: null, status: 'unauthenticated', error: null });
  },

  hydrate: async () => {
    // Uygulama açılışında saklı oturumu geri yükle.
    const [token, rawUser] = await Promise.all([
      secureStore.getItem(STORAGE_KEYS.accessToken),
      secureStore.getItem(STORAGE_KEYS.user),
    ]);
    if (token && rawUser) {
      try {
        const user = JSON.parse(rawUser) as AuthUser;
        set({ user, status: 'authenticated', hydrated: true });
        return;
      } catch {
        // Bozuk kayıt → temizle
      }
    }
    set({ status: 'unauthenticated', hydrated: true });
  },
}));

// 401 sonrası refresh başarısız olduğunda oturumu kapat.
setOnSessionExpired(() => {
  void useAuthStore.getState().logout();
});
