import { Text } from 'react-native';

/** Emoji tabanlı basit sekme ikonu (ek ikon paketi gerektirmez). */
export function TabBarIcon({ emoji, color }: { emoji: string; color: string }) {
  return <Text style={{ fontSize: 20, opacity: color === '#93A0B5' ? 0.6 : 1 }}>{emoji}</Text>;
}
