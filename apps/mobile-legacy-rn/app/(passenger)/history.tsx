import { StyleSheet, Text, View } from 'react-native';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { Card } from '@/components/Card';
import { StatusBadge } from '@/components/StatusBadge';
import { spacing, typography } from '@/theme';
import { formatDate } from '@/lib/format';

// Geçmiş yolculuklar (demo veri).
const HISTORY = [
  { id: 'h-1', date: '2026-08-01', name: 'Avrupa Yakası Sabah Servisi', onTime: true },
  { id: 'h-2', date: '2026-07-31', name: 'Avrupa Yakası Akşam Servisi', onTime: false },
  { id: 'h-3', date: '2026-07-31', name: 'Avrupa Yakası Sabah Servisi', onTime: true },
  { id: 'h-4', date: '2026-07-30', name: 'Avrupa Yakası Akşam Servisi', onTime: true },
];

/** Yolcu geçmiş yolculukları. */
export default function HistoryScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Geçmiş" subtitle="Önceki yolculuklarınız" />
      {HISTORY.map((h) => (
        <Card key={h.id} style={styles.row}>
          <View style={styles.flex}>
            <Text style={typography.bodyStrong}>{h.name}</Text>
            <Text style={typography.tiny}>{formatDate(h.date)}</Text>
          </View>
          <StatusBadge
            kind="custom"
            label={h.onTime ? 'Zamanında' : 'Gecikmeli'}
            tone={h.onTime ? 'success' : 'warning'}
          />
        </Card>
      ))}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
