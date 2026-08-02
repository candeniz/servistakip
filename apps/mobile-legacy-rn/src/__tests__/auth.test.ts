import { useAuthStore } from '@/stores/authStore';
import { ROLES } from '@servis/shared';

describe('kimlik doğrulama (mock)', () => {
  beforeEach(async () => {
    await useAuthStore.getState().logout();
  });

  it('doğru demo bilgileriyle giriş yapılır ve rol atanır', async () => {
    await useAuthStore.getState().login('sofor@demo.com', 'Demo123!');
    const { user, status } = useAuthStore.getState();
    expect(status).toBe('authenticated');
    expect(user?.role).toBe(ROLES.DRIVER);
    expect(user?.email).toBe('sofor@demo.com');
  });

  it('hatalı şifre girişi reddeder', async () => {
    await expect(useAuthStore.getState().login('yolcu@demo.com', 'yanlis')).rejects.toThrow();
    expect(useAuthStore.getState().status).toBe('unauthenticated');
  });

  it('çıkış yapınca oturum temizlenir', async () => {
    await useAuthStore.getState().login('yonetici@demo.com', 'Demo123!');
    await useAuthStore.getState().logout();
    expect(useAuthStore.getState().user).toBeNull();
  });
});
