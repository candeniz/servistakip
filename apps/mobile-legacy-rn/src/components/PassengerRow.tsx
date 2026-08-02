import { StyleSheet, Text, View } from 'react-native';
import { BOARDING_STATUS, type BoardingStatus, type TripPassenger } from '@servis/shared';
import { colors, spacing, typography } from '@/theme';
import { Card } from './Card';
import { StatusBadge } from './StatusBadge';
import { UserAvatar } from './UserAvatar';

interface PassengerRowProps {
  passenger: TripPassenger;
  onSetStatus?: (status: BoardingStatus) => void;
}

const ACTIONS: Array<{ status: BoardingStatus; label: string }> = [
  { status: BOARDING_STATUS.BOARDED, label: 'Bindi' },
  { status: BOARDING_STATUS.NO_SHOW, label: 'Gelmedi' },
  { status: BOARDING_STATUS.ABSENT, label: 'İzinli' },
  { status: BOARDING_STATUS.WRONG_STOP, label: 'Yanlış' },
];

/** Duraktaki yolcu satırı — şoför biniş durumunu işaretler. */
export function PassengerRow({ passenger, onSetStatus }: PassengerRowProps) {
  return (
    <Card style={styles.card}>
      <View style={styles.header}>
        <UserAvatar name={passenger.passenger_name} size={38} />
        <View style={styles.flex}>
          <Text style={typography.bodyStrong}>{passenger.passenger_name}</Text>
          <Text style={typography.tiny}>{passenger.stop_name}</Text>
        </View>
        <StatusBadge kind="boarding" value={passenger.boarding_status} />
      </View>
      {onSetStatus ? (
        <View style={styles.actions}>
          {ACTIONS.map((a) => {
            const active = passenger.boarding_status === a.status;
            return (
              <Text
                key={a.status}
                onPress={() => onSetStatus(a.status)}
                style={[styles.action, active && styles.actionActive]}
              >
                {a.label}
              </Text>
            );
          })}
        </View>
      ) : null}
    </Card>
  );
}

const styles = StyleSheet.create({
  card: { gap: spacing.sm },
  header: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  flex: { flex: 1, gap: 2 },
  actions: {
    flexDirection: 'row',
    gap: spacing.xs,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.border,
    paddingTop: spacing.sm,
  },
  action: {
    ...typography.label,
    flex: 1,
    textAlign: 'center',
    paddingVertical: spacing.sm,
    borderRadius: 8,
    backgroundColor: colors.surfaceAlt,
    color: colors.textSecondary,
    overflow: 'hidden',
  },
  actionActive: { backgroundColor: colors.primary, color: colors.textInverse },
});
