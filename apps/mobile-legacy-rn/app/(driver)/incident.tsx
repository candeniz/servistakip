import { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { INCIDENT_TYPE, INCIDENT_TYPE_LABELS, type IncidentType } from '@servis/shared';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { Card } from '@/components/Card';
import { borderRadius, colors, spacing, typography } from '@/theme';

const schema = z.object({ description: z.string().min(5, 'Açıklama en az 5 karakter olmalı') });
type FormValues = z.infer<typeof schema>;

const TYPES = Object.values(INCIDENT_TYPE);

/** Şoför olay bildirimi (gecikme, trafik, arıza, kaza). */
export default function IncidentScreen() {
  const [type, setType] = useState<IncidentType>(INCIDENT_TYPE.DELAY);
  const [sent, setSent] = useState(false);
  const { control, handleSubmit, formState } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { description: '' },
  });

  const onSubmit = () => {
    setSent(true);
    setTimeout(() => router.back(), 700);
  };

  return (
    <ScreenContainer>
      <AppHeader title="Olay Bildir" subtitle="Yöneticiye anlık iletilir" />

      <Text style={typography.label}>OLAY TÜRÜ</Text>
      <View style={styles.types}>
        {TYPES.map((t) => (
          <TouchableOpacity
            key={t}
            style={[styles.typeChip, type === t && styles.typeActive]}
            onPress={() => setType(t)}
          >
            <Text style={[typography.bodyStrong, { color: type === t ? colors.textInverse : colors.textSecondary }]}>
              {INCIDENT_TYPE_LABELS[t]}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <Card style={styles.form}>
        <Controller
          control={control}
          name="description"
          render={({ field: { value, onChange } }) => (
            <TextField
              label="Açıklama"
              value={value}
              onChangeText={onChange}
              placeholder="Kısa açıklama girin…"
              multiline
              numberOfLines={4}
              style={styles.textarea}
              error={formState.errors.description?.message}
            />
          )}
        />
        {sent ? <Text style={styles.success}>Olay bildirildi ✓</Text> : null}
        <PrimaryButton label={sent ? 'Bildirildi ✓' : 'Olayı Bildir'} onPress={handleSubmit(onSubmit)} disabled={sent} />
      </Card>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  types: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  typeChip: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
    borderRadius: borderRadius.pill,
    backgroundColor: colors.surfaceAlt,
  },
  typeActive: { backgroundColor: colors.primary },
  form: { gap: spacing.md },
  textarea: { height: 110, textAlignVertical: 'top', paddingTop: spacing.md },
  success: { ...typography.caption, color: colors.success },
});
