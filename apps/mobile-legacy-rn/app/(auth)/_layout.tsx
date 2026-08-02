import { Stack } from 'expo-router';

/** Kimlik doğrulama akışı — başlıksız stack. */
export default function AuthLayout() {
  return <Stack screenOptions={{ headerShown: false }} />;
}
