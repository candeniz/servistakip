import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { Card } from '@/components/Card';
import { StatusBadge } from '@/components/StatusBadge';
import { StyleSheet, Text, View } from 'react-native';
import { spacing, typography } from '@/theme';

interface Ticket {
  id: string;
  company: string;
  subject: string;
  status: 'open' | 'pending' | 'closed';
}

// Destek talepleri (demo veri).
const TICKETS: Ticket[] = [
  { id: 't-1', company: 'Atlas Teknoloji', subject: 'Şoför uygulamaya giriş yapamıyor', status: 'open' },
  { id: 't-2', company: 'Nova Lojistik', subject: 'Ek araç limiti talebi', status: 'pending' },
  { id: 't-3', company: 'Delta Üretim', subject: 'Fatura sorusu', status: 'closed' },
];

const TONE = { open: 'danger', pending: 'warning', closed: 'neutral' } as const;
const LABEL = { open: 'Açık', pending: 'Beklemede', closed: 'Kapalı' } as const;

/** Destek talepleri listesi. */
export default function SupportScreen() {
  return (
    <ScreenContainer>
      <AppHeader title="Destek" subtitle="Müşteri talepleri" />
      {TICKETS.map((t) => (
        <Card key={t.id} style={styles.card}>
          <View style={styles.row}>
            <View style={styles.flex}>
              <Text style={typography.bodyStrong}>{t.subject}</Text>
              <Text style={typography.tiny}>{t.company}</Text>
            </View>
            <StatusBadge kind="custom" label={LABEL[t.status]} tone={TONE[t.status]} />
          </View>
        </Card>
      ))}
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  card: {},
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
