export { colors } from './colors';
export type { ColorToken } from './colors';
export { spacing } from './spacing';
export type { SpacingToken } from './spacing';
export { typography } from './typography';
export type { TypographyToken } from './typography';
export { borderRadius } from './radius';
export type { RadiusToken } from './radius';
export { shadows } from './shadows';
export type { ShadowToken } from './shadows';

import { colors } from './colors';
import { spacing } from './spacing';
import { typography } from './typography';
import { borderRadius } from './radius';
import { shadows } from './shadows';

/** Tek noktadan erişim için birleşik tema nesnesi. */
export const theme = { colors, spacing, typography, borderRadius, shadows } as const;
export type Theme = typeof theme;
