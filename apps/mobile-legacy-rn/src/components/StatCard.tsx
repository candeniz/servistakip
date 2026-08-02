import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';

interface StatCardProps {
  label: string;
  value: string | number;
  hint?: string;
  tone?: 'default' | 'success' | 'warning' | 'danger';
}

const TONE_COLOR = {
  default: colors.text,
  success: colors.success,
  warning: colors.warning,
  danger: colors.danger,
} as const;

/** Küçük istatistik kartı (dashboard). */
export function StatCard({ label, value, hint, tone = 'default' }: StatCardProps) {
  return (
    <Card style={styles.card}>
      <Text style={typography.label}>{label}</Text>
      <Text style={[styles.value, { color: TONE_COLOR[tone] }]}>{value}</Text>
      {hint ? <Text style={typography.tiny}>{hint}</Text> : null}
    </Card>
  );
}

const styles = StyleSheet.create({
  card: { flex: 1, minWidth: 140, gap: spacing.xs },
  value: { ...typography.display, fontSize: 26, lineHeight: 30 },
});
