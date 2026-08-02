import { Tabs } from 'expo-router';
import { ROLES } from '@servis/shared';
import { AuthGuard } from '@/guards/AuthGuard';
import { RoleGuard } from '@/guards/RoleGuard';
import { TabBarIcon } from '@/components/TabBarIcon';
import { colors } from '@/theme';

/** Yönetici sekme navigasyonu — company_admin ve operations_manager erişebilir. */
export default function CompanyAdminLayout() {
  return (
    <AuthGuard>
      <RoleGuard allow={[ROLES.COMPANY_ADMIN, ROLES.OPERATIONS_MANAGER]}>
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
            name="live"
            options={{ title: 'Canlı Takip', tabBarIcon: ({ color }) => <TabBarIcon emoji="🗺️" color={color} /> }}
          />
          <Tabs.Screen
            name="services"
            options={{ title: 'Servisler', tabBarIcon: ({ color }) => <TabBarIcon emoji="🚌" color={color} /> }}
          />
          <Tabs.Screen
            name="people"
            options={{ title: 'Kişiler', tabBarIcon: ({ color }) => <TabBarIcon emoji="👥" color={color} /> }}
          />
          <Tabs.Screen
            name="management"
            options={{ title: 'Yönetim', tabBarIcon: ({ color }) => <TabBarIcon emoji="⚙️" color={color} /> }}
          />
          {/* Sekme çubuğunda görünmeyen detay ekranları */}
          <Tabs.Screen name="trip/[id]" options={{ href: null }} />
          <Tabs.Screen name="announcement" options={{ href: null }} />
        </Tabs>
      </RoleGuard>
    </AuthGuard>
  );
}
