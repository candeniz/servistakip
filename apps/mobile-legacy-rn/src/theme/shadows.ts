import { Platform, ViewStyle } from 'react-native';

/** Platforma göre gölge token'ları (iOS shadow* / Android elevation). */
function shadow(elevation: number, opacity: number, radius: number, offsetY: number): ViewStyle {
  return Platform.select<ViewStyle>({
    ios: {
      shadowColor: '#0F1B2D',
      shadowOpacity: opacity,
      shadowRadius: radius,
      shadowOffset: { width: 0, height: offsetY },
    },
    android: { elevation },
    default: {},
  }) as ViewStyle;
}

export const shadows = {
  none: {} as ViewStyle,
  sm: shadow(2, 0.06, 4, 1),
  md: shadow(4, 0.08, 10, 3),
  lg: shadow(8, 0.12, 18, 6),
} as const;

export type ShadowToken = keyof typeof shadows;
