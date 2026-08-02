import { StyleSheet, Text, TextInput, TextInputProps, View } from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';

interface TextFieldProps extends TextInputProps {
  label: string;
  error?: string;
}

/** Etiketli metin girişi + hata mesajı (formlar için). */
export function TextField({ label, error, style, ...rest }: TextFieldProps) {
  return (
    <View style={styles.container}>
      <Text style={typography.label}>{label}</Text>
      <TextInput
        style={[styles.input, error ? styles.inputError : null, style]}
        placeholderTextColor={colors.textMuted}
        {...rest}
      />
      {error ? <Text style={styles.error}>{error}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { gap: spacing.xs },
  input: {
    ...typography.body,
    height: 50,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.md,
    backgroundColor: colors.surface,
  },
  inputError: { borderColor: colors.danger },
  error: { ...typography.caption, color: colors.danger },
});
