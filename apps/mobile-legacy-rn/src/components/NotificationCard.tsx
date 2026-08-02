import { StyleSheet, Text, View } from 'react-native';
import type { AppNotification } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';
import { formatRelative } from '@/lib/format';

/** Bildirim listesi öğesi. Okunmamışsa vurgulanır. */
export function NotificationCard({ notification }: { notification: AppNotification }) {
  const unread = !notification.read_at;
  return (
    <Card style={styles.card}>
      <View style={[styles.dot, { backgroundColor: unread ? colors.primary : 'transparent' }]} />
      <View style={styles.flex}>
        <Text style={[typography.bodyStrong, !unread && { color: colors.textSecondary }]}>
          {notification.title}
        </Text>
        <Text style={typography.caption}>{notification.message}</Text>
        <Text style={typography.tiny}>{formatRelative(notification.created_at)}</Text>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', gap: spacing.md, alignItems: 'flex-start' },
  dot: { width: 8, height: 8, borderRadius: 4, marginTop: 6 },
  flex: { flex: 1, gap: 2 },
});
