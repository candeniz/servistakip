import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';

interface AppHeaderProps {
  title: string;
  subtitle?: string;
  right?: { label: string; onPress: () => void };
}

/** Ekran başlığı ve opsiyonel sağ aksiyon. */
export function AppHeader({ title, subtitle, right }: AppHeaderProps) {
  return (
    <View style={styles.row}>
      <View style={styles.flex}>
        <Text style={typography.h1} numberOfLines={1}>
          {title}
        </Text>
        {subtitle ? (
          <Text style={[typography.caption, styles.subtitle]} numberOfLines={1}>
            {subtitle}
          </Text>
        ) : null}
      </View>
      {right ? (
        <TouchableOpacity onPress={right.onPress} hitSlop={8}>
          <Text style={styles.action}>{right.label}</Text>
        </TouchableOpacity>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1 },
  subtitle: { marginTop: 2 },
  action: { ...typography.bodyStrong, color: colors.primary },
});
