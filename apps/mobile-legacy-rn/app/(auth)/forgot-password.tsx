import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { spacing, typography } from '@/theme';
import { forgotPasswordSchema, type ForgotPasswordForm } from '@/lib/validation';

/** Şifremi unuttum — doğrulama kodu ekranına yönlendirir (mock akış). */
export default function ForgotPasswordScreen() {
  const [sent, setSent] = useState(false);
  const { control, handleSubmit, formState } = useForm<ForgotPasswordForm>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: { email: '' },
  });

  const onSubmit = () => {
    // Mock: kod gönderildi kabul edilir.
    setSent(true);
    setTimeout(() => router.push('/(auth)/verify-code'), 600);
  };

  return (
    <ScreenContainer>
      <AppHeader title="Şifremi Unuttum" subtitle="E-postanıza doğrulama kodu gönderilir" />
      <View style={styles.form}>
        <Controller
          control={control}
          name="email"
          render={({ field: { value, onChange, onBlur } }) => (
            <TextField
              label="E-posta"
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
        <PrimaryButton
          label={sent ? 'Kod gönderildi ✓' : 'Kod Gönder'}
          onPress={handleSubmit(onSubmit)}
          disabled={sent}
        />
        <Text style={typography.tiny}>
          Demo modunda gerçek e-posta gönderilmez; sonraki ekranda herhangi 6 haneli kodu girebilirsiniz.
        </Text>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  form: { gap: spacing.md, marginTop: spacing.md },
});
