import { useState } from 'react';
import { StyleSheet, Text } from 'react-native';
import { router } from 'expo-router';
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { TextField } from '@/components/TextField';
import { PrimaryButton } from '@/components/PrimaryButton';
import { Card } from '@/components/Card';
import { colors, spacing, typography } from '@/theme';

const schema = z.object({
  title: z.string().min(3, 'Başlık en az 3 karakter olmalı'),
  content: z.string().min(5, 'İçerik en az 5 karakter olmalı'),
});
type FormValues = z.infer<typeof schema>;

/** Duyuru oluşturma + push bildirim (mock). */
export default function AnnouncementScreen() {
  const [sent, setSent] = useState(false);
  const { control, handleSubmit, formState } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { title: '', content: '' },
  });

  const onSubmit = () => {
    setSent(true);
    setTimeout(() => router.back(), 700);
  };

  return (
    <ScreenContainer>
      <AppHeader title="Duyuru Oluştur" subtitle="Tüm personele bildirim gönderilir" />
      <Card style={styles.form}>
        <Controller
          control={control}
          name="title"
          render={({ field: { value, onChange } }) => (
            <TextField label="Başlık" value={value} onChangeText={onChange} placeholder="Servis saati değişikliği" error={formState.errors.title?.message} />
          )}
        />
        <Controller
          control={control}
          name="content"
          render={({ field: { value, onChange } }) => (
            <TextField
              label="İçerik"
              value={value}
              onChangeText={onChange}
              placeholder="Yarınki sabah servisi 15 dk erken kalkacaktır."
              multiline
              numberOfLines={4}
              style={styles.textarea}
              error={formState.errors.content?.message}
            />
          )}
        />
        {sent ? <Text style={styles.success}>Duyuru gönderildi ✓</Text> : null}
        <PrimaryButton label={sent ? 'Gönderildi ✓' : 'Duyuru Gönder'} onPress={handleSubmit(onSubmit)} disabled={sent} />
        <Text style={typography.tiny}>Demo modunda gerçek push bildirimi gönderilmez.</Text>
      </Card>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  form: { gap: spacing.md },
  textarea: { height: 110, textAlignVertical: 'top', paddingTop: spacing.md },
  success: { ...typography.caption, color: colors.success },
});
