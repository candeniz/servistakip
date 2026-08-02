import { Modal, StyleSheet, Text, View } from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';
import { PrimaryButton } from './PrimaryButton';
import { SecondaryButton } from './SecondaryButton';

interface ConfirmationModalProps {
  visible: boolean;
  title: string;
  message?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  destructive?: boolean;
  loading?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/** Onay diyaloğu (servis başlat/tamamla/iptal gibi kritik işlemler). */
export function ConfirmationModal({
  visible,
  title,
  message,
  confirmLabel = strings.common.confirm,
  cancelLabel = strings.common.cancel,
  destructive = false,
  loading = false,
  onConfirm,
  onCancel,
}: ConfirmationModalProps) {
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onCancel}>
      <View style={styles.backdrop}>
        <View style={styles.sheet}>
          <Text style={typography.h2}>{title}</Text>
          {message ? <Text style={typography.caption}>{message}</Text> : null}
          <View style={styles.actions}>
            <SecondaryButton label={cancelLabel} onPress={onCancel} style={styles.flex} />
            <PrimaryButton
              label={confirmLabel}
              onPress={onConfirm}
              loading={loading}
              variant={destructive ? 'danger' : 'primary'}
              style={styles.flex}
            />
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: { flex: 1, backgroundColor: colors.overlay, justifyContent: 'center', padding: spacing.xl },
  sheet: {
    backgroundColor: colors.surface,
    borderRadius: borderRadius.xl,
    padding: spacing.xl,
    gap: spacing.md,
  },
  actions: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.sm },
  flex: { flex: 1 },
});
