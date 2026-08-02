/** Köşe yuvarlaklık token'ları. */
export const borderRadius = {
  none: 0,
  sm: 6,
  md: 10,
  lg: 14,
  xl: 20,
  '2xl': 28,
  pill: 999,
  full: 9999,
} as const;

export type RadiusToken = keyof typeof borderRadius;
