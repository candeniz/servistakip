import { ReactNode } from 'react';
import { ScrollView, StyleSheet, View, ViewStyle, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors, spacing } from '@/theme';

interface ScreenContainerProps {
  children: ReactNode;
  scroll?: boolean;
  padded?: boolean;
  style?: ViewStyle;
  refreshing?: boolean;
  onRefresh?: () => void;
  edges?: ('top' | 'bottom' | 'left' | 'right')[];
}

/** Tüm ekranların ortak kabuğu: güvenli alan + arka plan + opsiyonel scroll. */
export function ScreenContainer({
  children,
  scroll = true,
  padded = true,
  style,
  refreshing,
  onRefresh,
  edges = ['top'],
}: ScreenContainerProps) {
  const inner = [padded && styles.padded, style].filter(Boolean) as ViewStyle[];

  return (
    <SafeAreaView style={styles.safe} edges={edges}>
      {scroll ? (
        <ScrollView
          contentContainerStyle={[styles.scrollContent, ...inner]}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
          refreshControl={
            onRefresh ? (
              <RefreshControl refreshing={!!refreshing} onRefresh={onRefresh} tintColor={colors.primary} />
            ) : undefined
          }
        >
          {children}
        </ScrollView>
      ) : (
        <View style={[styles.flex, ...inner]}>{children}</View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.background },
  flex: { flex: 1 },
  scrollContent: { flexGrow: 1 },
  padded: { padding: spacing.lg, gap: spacing.md },
});
