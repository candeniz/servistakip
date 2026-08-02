import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';
import { BottomActionSheet } from './BottomActionSheet';

export interface FilterOption<T extends string> {
  value: T;
  label: string;
}

interface FilterSheetProps<T extends string> {
  visible: boolean;
  title: string;
  options: FilterOption<T>[];
  selected: T;
  onSelect: (value: T) => void;
  onClose: () => void;
}

/** Tek seçimli filtre kağıdı (durum/yön filtreleri). */
export function FilterSheet<T extends string>({
  visible,
  title,
  options,
  selected,
  onSelect,
  onClose,
}: FilterSheetProps<T>) {
  return (
    <BottomActionSheet visible={visible} title={title} onClose={onClose}>
      <View style={styles.list}>
        {options.map((opt) => {
          const active = opt.value === selected;
          return (
            <TouchableOpacity
              key={opt.value}
              style={[styles.option, active && styles.optionActive]}
              onPress={() => {
                onSelect(opt.value);
                onClose();
              }}
            >
              <Text style={[typography.body, active && styles.optionActiveText]}>{opt.label}</Text>
              {active ? <Text style={styles.check}>✓</Text> : null}
            </TouchableOpacity>
          );
        })}
      </View>
    </BottomActionSheet>
  );
}

const styles = StyleSheet.create({
  list: { gap: spacing.xs },
  option: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.md,
    borderRadius: borderRadius.md,
    backgroundColor: colors.surfaceAlt,
  },
  optionActive: { backgroundColor: colors.primaryLight },
  optionActiveText: { color: colors.primary, fontWeight: '700' },
  check: { color: colors.primary, fontWeight: '700', fontSize: 16 },
});
