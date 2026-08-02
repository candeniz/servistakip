/**
 * Sistem genelinde kullanılan roller.
 * Backend JWT içindeki `role` claim'i ile birebir eşleşir.
 */
export const ROLES = {
  SUPER_ADMIN: 'super_admin',
  COMPANY_ADMIN: 'company_admin',
  OPERATIONS_MANAGER: 'operations_manager',
  DRIVER: 'driver',
  PASSENGER: 'passenger',
} as const;

export type Role = (typeof ROLES)[keyof typeof ROLES];

export const ALL_ROLES: Role[] = Object.values(ROLES);

/**
 * Her rolün giriş sonrası yönlendirileceği Expo Router route group'u.
 * operations_manager, company_admin ile aynı yönetici arayüzünü paylaşır.
 */
export const ROLE_HOME_SEGMENT: Record<Role, string> = {
  [ROLES.SUPER_ADMIN]: '(super-admin)',
  [ROLES.COMPANY_ADMIN]: '(company-admin)',
  [ROLES.OPERATIONS_MANAGER]: '(company-admin)',
  [ROLES.DRIVER]: '(driver)',
  [ROLES.PASSENGER]: '(passenger)',
};

/** İnsan tarafından okunabilir rol etiketleri (Türkçe UI). */
export const ROLE_LABELS: Record<Role, string> = {
  [ROLES.SUPER_ADMIN]: 'Süper Admin',
  [ROLES.COMPANY_ADMIN]: 'Yönetici',
  [ROLES.OPERATIONS_MANAGER]: 'Operasyon Yetkilisi',
  [ROLES.DRIVER]: 'Şoför',
  [ROLES.PASSENGER]: 'Yolcu',
};

export function isRole(value: unknown): value is Role {
  return typeof value === 'string' && (ALL_ROLES as string[]).includes(value);
}
