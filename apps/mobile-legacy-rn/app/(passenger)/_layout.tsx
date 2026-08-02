import { Tabs } from 'expo-router';
import { ROLES } from '@servis/shared';
import { AuthGuard } from '@/guards/AuthGuard';
import { RoleGuard } from '@/guards/RoleGuard';
import { TabBarIcon } from '@/components/TabBarIcon';
import { colors } from '@/theme';

/** Yolcu sekme navigasyonu — yalnızca passenger erişebilir. */
export default function PassengerLayout() {
  return (
    <AuthGuard>
      <RoleGuard allow={[ROLES.PASSENGER]}>
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
            name="my-service"
            options={{ title: 'Servisim', tabBarIcon: ({ color }) => <TabBarIcon emoji="🚌" color={color} /> }}
          />
          <Tabs.Screen
            name="notifications"
            options={{ title: 'Bildirimler', tabBarIcon: ({ color }) => <TabBarIcon emoji="🔔" color={color} /> }}
          />
          <Tabs.Screen
            name="history"
            options={{ title: 'Geçmiş', tabBarIcon: ({ color }) => <TabBarIcon emoji="🕘" color={color} /> }}
          />
          <Tabs.Screen
            name="profile"
            options={{ title: 'Profil', tabBarIcon: ({ color }) => <TabBarIcon emoji="👤" color={color} /> }}
          />
        </Tabs>
      </RoleGuard>
    </AuthGuard>
  );
}
