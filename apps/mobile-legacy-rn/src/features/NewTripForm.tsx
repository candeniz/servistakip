import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { Card } from '@/components/Card';
import { colors, spacing, typography } from '@/theme';

// Yeni servis oluşturma doğrulaması.
const schema = z.object({
  name: z.string().min(3, 'Servis adı en az 3 karakter olmalı'),
  startTime: z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Saat SS:DD biçiminde olmalı'),
  plate: z.string().min(4, 'Plaka gerekli'),
  driver: z.string().min(2, 'Şoför adı gerekli'),
});
type FormValues = z.infer<typeof schema>;

/** Servis tanımı oluşturma formu (mock: yerel olarak onaylar). */
export function NewTripForm() {
  const [created, setCreated] = useState(false);
  const { control, handleSubmit, formState } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { name: '', startTime: '06:30', plate: '', driver: '' },
  });

  const onSubmit = () => {
    // Mock: gerçek API çağrısı yerine başarı gösterilir.
    setCreated(true);
    setTimeout(() => router.back(), 700);
  };

  return (
    <Card style={styles.form}>
      <Controller
        control={control}
        name="name"
        render={({ field: { value, onChange } }) => (
          <TextField label="Servis Adı" value={value} onChangeText={onChange} placeholder="Avrupa Yakası Sabah Servisi" error={formState.errors.name?.message} />
        )}
      />
      <Controller
        control={control}
        name="startTime"
        render={({ field: { value, onChange } }) => (
          <TextField label="Kalkış Saati" value={value} onChangeText={onChange} placeholder="06:30" error={formState.errors.startTime?.message} />
        )}
      />
      <Controller
        control={control}
        name="plate"
        render={({ field: { value, onChange } }) => (
          <TextField label="Araç Plakası" value={value} onChangeText={onChange} placeholder="34 ST 2026" autoCapitalize="characters" error={formState.errors.plate?.message} />
        )}
      />
      <Controller
        control={control}
        name="driver"
        render={({ field: { value, onChange } }) => (
          <TextField label="Şoför" value={value} onChangeText={onChange} placeholder="Mehmet Yılmaz" error={formState.errors.driver?.message} />
        )}
      />

      {created ? <Text style={styles.success}>Servis oluşturuldu ✓</Text> : null}

      <PrimaryButton label={created ? 'Oluşturuldu ✓' : 'Servisi Oluştur'} onPress={handleSubmit(onSubmit)} disabled={created} />
      <Text style={typography.tiny}>
        Demo modunda servis yalnızca yerel olarak oluşturulur; backend bağlandığında POST /service-definitions çağrılır.
      </Text>
    </Card>
  );
}

const styles = StyleSheet.create({
  form: { gap: spacing.md },
  success: { ...typography.caption, color: colors.success },
});
