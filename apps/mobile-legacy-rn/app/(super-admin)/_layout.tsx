import { Tabs } from 'expo-router';
import { ROLES } from '@servis/shared';
import { AuthGuard } from '@/guards/AuthGuard';
import { RoleGuard } from '@/guards/RoleGuard';
import { TabBarIcon } from '@/components/TabBarIcon';
import { colors } from '@/theme';

/** Süper Admin sekme navigasyonu — yalnızca super_admin erişebilir. */
export default function SuperAdminLayout() {
  return (
    <AuthGuard>
      <RoleGuard allow={[ROLES.SUPER_ADMIN]}>
        <Tabs
          screenOptions={{
            headerShown: false,
            tabBarActiveTintColor: colors.primary,
            tabBarInactiveTintColor: colors.textMuted,
          }}
        >
          <Tabs.Screen
            name="index"
            options={{ title: 'Dashboard', tabBarIcon: ({ color }) => <TabBarIcon emoji="📊" color={color} /> }}
          />
          <Tabs.Screen
            name="customers"
            options={{ title: 'Müşteriler', tabBarIcon: ({ color }) => <TabBarIcon emoji="🏢" color={color} /> }}
          />
          <Tabs.Screen
            name="live"
            options={{ title: 'Operasyon', tabBarIcon: ({ color }) => <TabBarIcon emoji="🛰️" color={color} /> }}
          />
          <Tabs.Screen
            name="support"
            options={{ title: 'Destek', tabBarIcon: ({ color }) => <TabBarIcon emoji="💬" color={color} /> }}
          />
          <Tabs.Screen
            name="settings"
            options={{ title: 'Ayarlar', tabBarIcon: ({ color }) => <TabBarIcon emoji="⚙️" color={color} /> }}
          />
        </Tabs>
      </RoleGuard>
    </AuthGuard>
  );
}
