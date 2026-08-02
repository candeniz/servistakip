import { StyleSheet, Text, View } from 'react-native';
import { colors, spacing, typography } from '@/theme';

interface OfflineBannerProps {
  visible: boolean;
  message: string;
  tone?: 'danger' | 'warning';
}

/** Bağlantı / durum uyarı şeridi (ekran üstünde). */
export function OfflineBanner({ visible, message, tone = 'danger' }: OfflineBannerProps) {
  if (!visible) return null;
  const bg = tone === 'danger' ? colors.dangerBg : colors.warningBg;
  const fg = tone === 'danger' ? colors.danger : colors.warning;
  return (
    <View style={[styles.banner, { backgroundColor: bg }]}>
      <Text style={[typography.caption, { color: fg, fontWeight: '600' }]}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
    alignItems: 'center',
  },
});
