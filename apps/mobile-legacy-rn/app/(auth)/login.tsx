import { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ROLE_HOME_SEGMENT, ROLE_LABELS } from '@servis/shared';
import { ScreenContainer } from '@/components/ScreenContainer';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { Card } from '@/components/Card';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';
import { loginSchema, type LoginForm } from '@/lib/validation';
import { useAuthStore } from '@/stores/authStore';
import { DEMO_ACCOUNTS, DEMO_PASSWORD } from '@/mocks/demoUsers';

/** Tek giriş ekranı — başarılı girişte role göre yönlendirir. */
export default function LoginScreen() {
  const login = useAuthStore((s) => s.login);
  const authError = useAuthStore((s) => s.error);
  const [submitting, setSubmitting] = useState(false);

  const { control, handleSubmit, setValue, formState } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
  });

  const onSubmit = async (values: LoginForm) => {
    setSubmitting(true);
    try {
      const user = (await loginAndReturn(login, values)) ;
      if (user) router.replace(`/${ROLE_HOME_SEGMENT[user.role]}` as never);
    } catch {
      // Hata store.error üzerinden gösterilir.
    } finally {
      setSubmitting(false);
    }
  };

  const fillDemo = (email: string) => {
    setValue('email', email, { shouldValidate: true });
    setValue('password', DEMO_PASSWORD, { shouldValidate: true });
  };

  return (
    <ScreenContainer>
      <View style={styles.header}>
        <Text style={styles.logo}>🚐</Text>
        <Text style={typography.display}>{strings.app.name}</Text>
        <Text style={typography.caption}>{strings.app.tagline}</Text>
      </View>

      <Card style={styles.form}>
        <Text style={typography.h2}>{strings.auth.loginTitle}</Text>

        <Controller
          control={control}
          name="email"
          render={({ field: { value, onChange, onBlur } }) => (
            <TextField
              label={strings.auth.email}
              value={value}
              onChangeText={onChange}
              onBlur={onBlur}
              placeholder="ornek@sirket.com"
              autoCapitalize="none"
              keyboardType="email-address"
              error={formState.errors.email?.message}
            />
          )}
        />

        <Controller
          control={control}
          name="password"
          render={({ field: { value, onChange, onBlur } }) => (
            <TextField
              label={strings.auth.password}
              value={value}
              onChangeText={onChange}
              onBlur={onBlur}
              placeholder="••••••••"
              secureTextEntry
              error={formState.errors.password?.message}
            />
          )}
        />

        {authError ? <Text style={styles.error}>{authError}</Text> : null}

        <PrimaryButton
          label={strings.auth.loginButton}
          onPress={handleSubmit(onSubmit)}
          loading={submitting}
        />

        <TouchableOpacity onPress={() => router.push('/(auth)/forgot-password')}>
          <Text style={styles.link}>{strings.auth.forgotPassword}</Text>
        </TouchableOpacity>
      </Card>

      <View style={styles.demo}>
        <Text style={typography.label}>{strings.auth.demoHint}</Text>
        <View style={styles.demoGrid}>
          {DEMO_ACCOUNTS.map((acc) => (
            <TouchableOpacity
              key={acc.user.id}
              style={styles.demoChip}
              onPress={() => fillDemo(acc.user.email)}
            >
              <Text style={styles.demoRole}>{ROLE_LABELS[acc.user.role]}</Text>
              <Text style={typography.tiny}>{acc.user.email}</Text>
            </TouchableOpacity>
          ))}
        </View>
        <Text style={typography.tiny}>Tüm demo hesapların şifresi: {DEMO_PASSWORD}</Text>
      </View>
    </ScreenContainer>
  );
}

/** login çağrısını yapar ve güncel kullanıcıyı döndürür. */
async function loginAndReturn(
  login: (email: string, password: string) => Promise<void>,
  values: LoginForm,
) {
  await login(values.email, values.password);
  return useAuthStore.getState().user;
}

const styles = StyleSheet.create({
  header: { alignItems: 'center', gap: spacing.xs, marginTop: spacing['2xl'], marginBottom: spacing.lg },
  logo: { fontSize: 48 },
  form: { gap: spacing.md },
  error: { ...typography.caption, color: colors.danger },
  link: { ...typography.body, color: colors.primary, textAlign: 'center', marginTop: spacing.xs },
  demo: { gap: spacing.sm, marginTop: spacing.md },
  demoGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  demoChip: {
    flexGrow: 1,
    minWidth: '46%',
    backgroundColor: colors.surface,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    padding: spacing.md,
    gap: 2,
  },
  demoRole: { ...typography.bodyStrong, color: colors.primary },
});
