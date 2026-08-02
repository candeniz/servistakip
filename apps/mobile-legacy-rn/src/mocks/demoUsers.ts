import { ROLES, type Role } from '@servis/shared';
import type { AuthUser } from '@servis/shared';

/** Mock giriş için demo hesap kaydı (şifre dahil — yalnızca mock katmanında). */
export interface DemoAccount {
  password: string;
  user: AuthUser;
}

const TENANT_ID = 'tenant-atlas';
const TENANT_NAME = 'Atlas Teknoloji';

/** Tüm demo hesaplar için ortak şifre. */
export const DEMO_PASSWORD = 'Demo123!';

function user(
  id: string,
  role: Role,
  first: string,
  last: string,
  email: string,
  tenant: string | null,
  tenantName: string | null,
): AuthUser {
  return {
    id,
    tenant_id: tenant,
    first_name: first,
    last_name: last,
    email,
    phone: '+90 555 000 0000',
    role,
    status: 'active',
    profile_photo: null,
    tenant_name: tenantName,
  };
}

/** Dört demo hesap — hepsi Demo123! şifresiyle. */
export const DEMO_ACCOUNTS: DemoAccount[] = [
  {
    password: DEMO_PASSWORD,
    user: user('user-superadmin', ROLES.SUPER_ADMIN, 'Selin', 'Kaya', 'superadmin@demo.com', null, null),
  },
  {
    password: DEMO_PASSWORD,
    user: user('user-admin', ROLES.COMPANY_ADMIN, 'Ahmet', 'Demir', 'yonetici@demo.com', TENANT_ID, TENANT_NAME),
  },
  {
    password: DEMO_PASSWORD,
    user: user('user-driver', ROLES.DRIVER, 'Mehmet', 'Yılmaz', 'sofor@demo.com', TENANT_ID, TENANT_NAME),
  },
  {
    password: DEMO_PASSWORD,
    user: user('user-passenger', ROLES.PASSENGER, 'Zeynep', 'Arslan', 'yolcu@demo.com', TENANT_ID, TENANT_NAME),
  },
];

export const DEMO_TENANT_ID = TENANT_ID;
export const DEMO_DRIVER_ID = 'user-driver';
export const DEMO_PASSENGER_ID = 'user-passenger';
