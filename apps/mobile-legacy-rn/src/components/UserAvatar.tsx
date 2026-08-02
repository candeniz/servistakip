import { Image, StyleSheet, Text, View } from 'react-native';
import { borderRadius, colors, typography } from '@/theme';

interface UserAvatarProps {
  name: string;
  photoUrl?: string | null;
  size?: number;
}

/** Kullanıcı avatarı — foto yoksa baş harfler. */
export function UserAvatar({ name, photoUrl, size = 40 }: UserAvatarProps) {
  const initials = name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((n) => n[0]?.toUpperCase())
    .join('');

  const dimension = { width: size, height: size, borderRadius: size / 2 };

  if (photoUrl) {
    return <Image source={{ uri: photoUrl }} style={[styles.image, dimension]} />;
  }
  return (
    <View style={[styles.fallback, dimension]}>
      <Text style={[typography.bodyStrong, { color: colors.primary, fontSize: size * 0.38 }]}>
        {initials || '?'}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  image: { backgroundColor: colors.surfaceAlt },
  fallback: {
    backgroundColor: colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: borderRadius.pill,
  },
});
