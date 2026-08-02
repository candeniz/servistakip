import { StyleSheet, TextInput, View } from 'react-native';
import { borderRadius, colors, spacing, typography } from '@/theme';
import { strings } from '@/constants/strings';

interface SearchInputProps {
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
}

/** Arama kutusu. */
export function SearchInput({ value, onChangeText, placeholder = strings.common.search }: SearchInputProps) {
  return (
    <View style={styles.wrapper}>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={colors.textMuted}
        style={styles.input}
        autoCapitalize="none"
        autoCorrect={false}
        clearButtonMode="while-editing"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    backgroundColor: colors.surface,
    borderRadius: borderRadius.md,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.md,
  },
  input: { ...typography.body, height: 46 },
});
