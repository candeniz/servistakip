import { StyleSheet, Text, View } from 'react-native';
import { spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

interface EmptyStateProps {
  title?: string;
  description?: string;
  icon?: string;
}

/** Boş liste / veri yok durumu. */
export function EmptyState({ title = strings.common.noData, description, icon = '📭' }: EmptyStateProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.icon}>{icon}</Text>
      <Text style={[typography.h3, styles.center]}>{title}</Text>
      {description ? <Text style={[typography.caption, styles.center]}>{description}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { alignItems: 'center', justifyContent: 'center', gap: spacing.xs, padding: spacing['3xl'] },
  icon: { fontSize: 36, marginBottom: spacing.xs },
  center: { textAlign: 'center' },
});
