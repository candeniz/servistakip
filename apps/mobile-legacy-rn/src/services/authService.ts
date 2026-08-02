import type { AuthUser, LoginResponse } from '@servis/shared';
import { env } from '@/config/env';
import { api } from './apiClient';
import { DEMO_ACCOUNTS } from '@/mocks/demoUsers';

/** Kimlik doğrulama servis arayüzü — mock ve gerçek uygulamalar bunu paylaşır. */
export interface AuthService {
  login(email: string, password: string): Promise<LoginResponse>;
  me(): Promise<AuthUser>;
  logout(): Promise<void>;
}

/** Backend olmadan çalışan mock kimlik doğrulama. */
class MockAuthService implements AuthService {
  async login(email: string, password: string): Promise<LoginResponse> {
    // Gerçekçi bir gecikme
    await delay(400);
    const account = DEMO_ACCOUNTS.find(
      (a) => a.user.email.toLowerCase() === email.trim().toLowerCase(),
    );
    if (!account || account.password !== password) {
      throw new Error('E-posta veya şifre hatalı.');
    }
    return {
      user: account.user,
      tokens: {
        access_token: `mock-access-${account.user.id}`,
        refresh_token: `mock-refresh-${account.user.id}`,
        token_type: 'bearer',
        expires_in: 900,
      },
    };
  }

  async me(): Promise<AuthUser> {
    await delay(150);
    // Mock modda oturum kullanıcısı authStore tarafından tutulur.
    throw new Error('Mock modda /me authStore üzerinden okunur.');
  }

  async logout(): Promise<void> {
    await delay(100);
  }
}

/** Gerçek backend'e bağlanan kimlik doğrulama. */
class ApiAuthService implements AuthService {
  async login(email: string, password: string): Promise<LoginResponse> {
    const { data } = await api.post<LoginResponse>('/auth/login', { email, password });
    return data;
  }

  async me(): Promise<AuthUser> {
    const { data } = await api.get<AuthUser>('/auth/me');
    return data;
  }

  async logout(): Promise<void> {
    await api.post('/auth/logout');
  }
}

const delay = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));

/** Yapılandırmaya göre aktif servis (mock varsayılan). */
export const authService: AuthService = env.useMock ? new MockAuthService() : new ApiAuthService();
