import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { spacing, typography } from '@/theme';
import { verifyCodeSchema, type VerifyCodeForm } from '@/lib/validation';

/** Doğrulama kodu girişi (mock akış → giriş ekranına döner). */
export default function VerifyCodeScreen() {
  const { control, handleSubmit, formState } = useForm<VerifyCodeForm>({
    resolver: zodResolver(verifyCodeSchema),
    defaultValues: { code: '' },
  });

  const onSubmit = () => {
    router.replace('/(auth)/login');
  };

  return (
    <ScreenContainer>
      <AppHeader title="Doğrulama Kodu" subtitle="E-postanıza gelen 6 haneli kodu girin" />
      <View style={styles.form}>
        <Controller
          control={control}
          name="code"
          render={({ field: { value, onChange, onBlur } }) => (
            <TextField
              label="Kod"
              value={value}
              onChangeText={onChange}
              onBlur={onBlur}
              placeholder="000000"
              keyboardType="number-pad"
              maxLength={6}
              error={formState.errors.code?.message}
            />
          )}
        />
        <PrimaryButton label="Doğrula" onPress={handleSubmit(onSubmit)} />
        <Text style={typography.tiny}>Demo modunda herhangi 6 haneli kod kabul edilir.</Text>
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  form: { gap: spacing.md, marginTop: spacing.md },
});
