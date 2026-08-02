import { z } from 'zod';

/** Giriş formu doğrulaması. */
export const loginSchema = z.object({
  email: z.string().min(1, 'E-posta gerekli').email('Geçerli bir e-posta girin'),
  password: z.string().min(1, 'Şifre gerekli'),
});
export type LoginForm = z.infer<typeof loginSchema>;

/** Şifremi unuttum formu. */
export const forgotPasswordSchema = z.object({
  email: z.string().min(1, 'E-posta gerekli').email('Geçerli bir e-posta girin'),
});
export type ForgotPasswordForm = z.infer<typeof forgotPasswordSchema>;

/** Doğrulama kodu formu. */
export const verifyCodeSchema = z.object({
  code: z.string().length(6, 'Kod 6 haneli olmalı'),
});
export type VerifyCodeForm = z.infer<typeof verifyCodeSchema>;
