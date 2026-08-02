import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  ViewStyle,
} from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';

export interface PrimaryButtonProps {
  label: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  style?: ViewStyle;
  variant?: 'primary' | 'success' | 'danger';
}

const VARIANT_BG: Record<NonNullable<PrimaryButtonProps['variant']>, string> = {
  primary: colors.primary,
  success: colors.success,
  danger: colors.danger,
};

/** Birincil dolgulu buton. */
export function PrimaryButton({
  label,
  onPress,
  loading = false,
  disabled = false,
  style,
  variant = 'primary',
}: PrimaryButtonProps) {
  const isDisabled = disabled || loading;
  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled}
      accessibilityRole="button"
      style={({ pressed }) => [
        styles.base,
        { backgroundColor: VARIANT_BG[variant] },
        pressed && !isDisabled && styles.pressed,
        isDisabled && styles.disabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={colors.textInverse} />
      ) : (
        <Text style={styles.label}>{label}</Text>
      )}
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
  },
  pressed: { opacity: 0.85 },
  disabled: { opacity: 0.5 },
  label: { ...typography.bodyStrong, color: colors.textInverse },
});
