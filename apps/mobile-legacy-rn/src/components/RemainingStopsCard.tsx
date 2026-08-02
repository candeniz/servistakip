import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';

interface RemainingStopsCardProps {
  remainingStops: number;
  passengerStopName: string;
  nextStopName: string;
}

/** Yolcuya kaç durak kaldığını ve durak bilgisini vurgular. */
export function RemainingStopsCard({
  remainingStops,
  passengerStopName,
  nextStopName,
}: RemainingStopsCardProps) {
  return (
    <Card style={styles.card}>
      <View style={styles.badge}>
        <Text style={styles.count}>{remainingStops}</Text>
      </View>
      <View style={styles.flex}>
        <Text style={typography.bodyStrong}>Durağınıza {remainingStops} durak kaldı</Text>
        <Text style={typography.caption}>Durağınız: {passengerStopName}</Text>
        <Text style={typography.tiny}>Aracın sıradaki durağı: {nextStopName}</Text>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg },
  badge: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  count: { ...typography.display, fontSize: 26, lineHeight: 30, color: colors.primary },
  flex: { flex: 1, gap: 2 },
});
