import { ROLES, ROLE_HOME_SEGMENT, isRole, ALL_ROLES } from '@servis/shared';

describe('rol tanımları', () => {
  it('her rol için bir ana ekran segmenti tanımlıdır', () => {
    for (const role of ALL_ROLES) {
      expect(ROLE_HOME_SEGMENT[role]).toBeTruthy();
    }
  });

  it('operations_manager ve company_admin aynı yönetici arayüzünü paylaşır', () => {
    expect(ROLE_HOME_SEGMENT[ROLES.OPERATIONS_MANAGER]).toBe(ROLE_HOME_SEGMENT[ROLES.COMPANY_ADMIN]);
  });

  it('isRole geçerli/geçersiz değerleri ayırır', () => {
    expect(isRole('driver')).toBe(true);
    expect(isRole('hacker')).toBe(false);
    expect(isRole(123)).toBe(false);
  });
});
