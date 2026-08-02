import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

/** Tam ekran yükleniyor göstergesi. */
export function LoadingState({ message = strings.common.loading }: { message?: string }) {
  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color={colors.primary} />
      <Text style={[typography.caption, styles.text]}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.md,
    backgroundColor: colors.background,
    padding: spacing.xl,
  },
  text: { color: colors.textSecondary },
});
