import { Tabs } from 'expo-router';
import { ROLES } from '@servis/shared';
import { AuthGuard } from '@/guards/AuthGuard';
import { RoleGuard } from '@/guards/RoleGuard';
import { TabBarIcon } from '@/components/TabBarIcon';
import { colors } from '@/theme';

/** Şoför sekme navigasyonu — yalnızca driver erişebilir. */
export default function DriverLayout() {
  return (
    <AuthGuard>
      <RoleGuard allow={[ROLES.DRIVER]}>
        <Tabs
          screenOptions={{
            headerShown: false,
            tabBarActiveTintColor: colors.primary,
            tabBarInactiveTintColor: colors.textMuted,
          }}
        >
          <Tabs.Screen
            name="index"
            options={{ title: 'Ana Sayfa', tabBarIcon: ({ color }) => <TabBarIcon emoji="🏠" color={color} /> }}
          />
          <Tabs.Screen
            name="trip"
            options={{ title: 'Yolculuk', tabBarIcon: ({ color }) => <TabBarIcon emoji="🚐" color={color} /> }}
          />
          <Tabs.Screen
            name="passengers"
            options={{ title: 'Yolcular', tabBarIcon: ({ color }) => <TabBarIcon emoji="👥" color={color} /> }}
          />
          <Tabs.Screen
            name="notifications"
            options={{ title: 'Bildirimler', tabBarIcon: ({ color }) => <TabBarIcon emoji="🔔" color={color} /> }}
          />
          <Tabs.Screen
            name="profile"
            options={{ title: 'Profil', tabBarIcon: ({ color }) => <TabBarIcon emoji="👤" color={color} /> }}
          />
          <Tabs.Screen name="incident" options={{ href: null }} />
        </Tabs>
      </RoleGuard>
    </AuthGuard>
  );
}
