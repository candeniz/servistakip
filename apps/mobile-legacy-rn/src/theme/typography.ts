import { TextStyle } from 'react-native';
import { colors } from './colors';

/** Tipografi ölçeği. Sistem fontu kullanılır (ek font paketi gerektirmez). */
export const typography = {
  display: { fontSize: 30, lineHeight: 36, fontWeight: '700', color: colors.text } as TextStyle,
  h1: { fontSize: 24, lineHeight: 30, fontWeight: '700', color: colors.text } as TextStyle,
  h2: { fontSize: 20, lineHeight: 26, fontWeight: '700', color: colors.text } as TextStyle,
  h3: { fontSize: 17, lineHeight: 23, fontWeight: '600', color: colors.text } as TextStyle,
  body: { fontSize: 15, lineHeight: 22, fontWeight: '400', color: colors.text } as TextStyle,
  bodyStrong: { fontSize: 15, lineHeight: 22, fontWeight: '600', color: colors.text } as TextStyle,
  caption: { fontSize: 13, lineHeight: 18, fontWeight: '400', color: colors.textSecondary } as TextStyle,
  label: { fontSize: 12, lineHeight: 16, fontWeight: '600', color: colors.textSecondary } as TextStyle,
  tiny: { fontSize: 11, lineHeight: 14, fontWeight: '500', color: colors.textMuted } as TextStyle,
} as const;

export type TypographyToken = keyof typeof typography;
