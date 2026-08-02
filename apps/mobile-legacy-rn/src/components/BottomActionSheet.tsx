import { ReactNode } from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { borderRadius, colors, spacing, typography } from '@/theme';

interface BottomActionSheetProps {
  visible: boolean;
  title?: string;
  onClose: () => void;
  children: ReactNode;
}

/** Alttan açılan aksiyon/filtre kağıdı. */
export function BottomActionSheet({ visible, title, onClose, children }: BottomActionSheetProps) {
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <SafeAreaView edges={['bottom']} style={styles.sheetWrap}>
        <View style={styles.sheet}>
          <View style={styles.handle} />
          {title ? <Text style={typography.h3}>{title}</Text> : null}
          {children}
        </View>
      </SafeAreaView>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: { ...StyleSheet.absoluteFillObject, backgroundColor: colors.overlay },
  sheetWrap: { flex: 1, justifyContent: 'flex-end' },
  sheet: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: borderRadius['2xl'],
    borderTopRightRadius: borderRadius['2xl'],
    padding: spacing.xl,
    gap: spacing.md,
  },
  handle: {
    alignSelf: 'center',
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.border,
    marginBottom: spacing.sm,
  },
});
