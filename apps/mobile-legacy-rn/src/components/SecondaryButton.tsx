import { Pressable, StyleSheet, Text, ViewStyle } from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';

interface SecondaryButtonProps {
  label: string;
  onPress: () => void;
  disabled?: boolean;
  style?: ViewStyle;
}

/** İkincil (çerçeveli) buton. */
export function SecondaryButton({ label, onPress, disabled = false, style }: SecondaryButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      style={({ pressed }) => [styles.base, pressed && styles.pressed, disabled && styles.disabled, style]}
    >
      <Text style={styles.label}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    height: 52,
    borderRadius: borderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.lg,
    borderWidth: 1.5,
    borderColor: colors.primary,
    backgroundColor: colors.surface,
  },
  pressed: { backgroundColor: colors.primaryLight },
  disabled: { opacity: 0.5 },
  label: { ...typography.bodyStrong, color: colors.primary },
});
