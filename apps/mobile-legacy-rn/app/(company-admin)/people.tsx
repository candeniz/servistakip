import { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { ScreenContainer } from '@/components/ScreenContainer';
import { AppHeader } from '@/components/AppHeader';
import { Card } from '@/components/Card';
import { UserAvatar } from '@/components/UserAvatar';
import { StatusBadge } from '@/components/StatusBadge';
import { SearchInput } from '@/components/SearchInput';
import { demoTripPassengers } from '@/mocks/demoData';
import { borderRadius, colors, spacing, typography } from '@/theme';

type Segment = 'passengers' | 'drivers';

// Şoför örnek verisi (demo).
const DRIVERS = [
  { id: 'd-1', name: 'Mehmet Yılmaz', vehicle: '34 ST 2026', active: true },
  { id: 'd-2', name: 'Ali Vural', vehicle: '34 XY 1400', active: true },
  { id: 'd-3', name: 'Hasan Kaya', vehicle: '—', active: false },
];

/** Kişiler: personel/yolcu ve şoför listeleri (segment kontrolü). */
export default function PeopleScreen() {
  const [segment, setSegment] = useState<Segment>('passengers');
  const [search, setSearch] = useState('');

  return (
    <ScreenContainer>
      <AppHeader title="Kişiler" right={{ label: '+ Ekle', onPress: () => {} }} />

      <View style={styles.segment}>
        <SegmentButton label="Personel" active={segment === 'passengers'} onPress={() => setSegment('passengers')} />
        <SegmentButton label="Şoförler" active={segment === 'drivers'} onPress={() => setSegment('drivers')} />
      </View>

      <SearchInput value={search} onChangeText={setSearch} placeholder="İsim ara…" />

      {segment === 'passengers'
        ? demoTripPassengers
            .filter((p) => p.passenger_name.toLowerCase().includes(search.toLowerCase()))
            .map((p) => (
              <Card key={p.id} style={styles.row}>
                <UserAvatar name={p.passenger_name} size={38} />
                <View style={styles.flex}>
                  <Text style={typography.bodyStrong}>{p.passenger_name}</Text>
                  <Text style={typography.tiny}>Durak: {p.stop_name}</Text>
                </View>
              </Card>
            ))
        : DRIVERS.filter((d) => d.name.toLowerCase().includes(search.toLowerCase())).map((d) => (
            <Card key={d.id} style={styles.row}>
              <UserAvatar name={d.name} size={38} />
              <View style={styles.flex}>
                <Text style={typography.bodyStrong}>{d.name}</Text>
                <Text style={typography.tiny}>Araç: {d.vehicle}</Text>
              </View>
              <StatusBadge kind="custom" label={d.active ? 'Aktif' : 'Pasif'} tone={d.active ? 'success' : 'neutral'} />
            </Card>
          ))}
    </ScreenContainer>
  );
}

function SegmentButton({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <TouchableOpacity style={[styles.segmentBtn, active && styles.segmentActive]} onPress={onPress}>
      <Text style={[typography.bodyStrong, { color: active ? colors.textInverse : colors.textSecondary }]}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  segment: { flexDirection: 'row', gap: spacing.xs, backgroundColor: colors.surfaceAlt, padding: 4, borderRadius: borderRadius.md },
  segmentBtn: { flex: 1, paddingVertical: spacing.sm, alignItems: 'center', borderRadius: borderRadius.sm },
  segmentActive: { backgroundColor: colors.primary },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
});
