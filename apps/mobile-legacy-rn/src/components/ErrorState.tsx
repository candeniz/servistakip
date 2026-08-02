import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';
import { PrimaryButton } from './PrimaryButton';

interface ErrorStateProps {
  title?: string;
  description?: string;
  onRetry?: () => void;
}

/** Hata durumu görünümü + opsiyonel tekrar dene. */
export function ErrorState({ title = strings.common.error, description, onRetry }: ErrorStateProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.icon}>⚠️</Text>
      <Text style={[typography.h3, styles.center]}>{title}</Text>
      {description ? <Text style={[typography.caption, styles.center]}>{description}</Text> : null}
      {onRetry ? (
        <PrimaryButton label={strings.common.retry} onPress={onRetry} style={styles.button} />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing.sm, padding: spacing.xl },
  icon: { fontSize: 40, marginBottom: spacing.xs },
  center: { textAlign: 'center' },
  button: { marginTop: spacing.md, alignSelf: 'stretch' },
});
