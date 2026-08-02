import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Rol bazlı alt navigasyon kabuğu (StatefulShellRoute ile kullanılır).
class RoleShell extends StatelessWidget {
  const RoleShell({super.key, required this.navigationShell, required this.destinations});

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        indicatorColor: AppColors.primaryLight,
        destinations: destinations,
      ),
    );
  }
}

/// Emoji tabanlı sekme ikonu (ek ikon paketi gerektirmez).
NavigationDestination navDestination(String emoji, String label) => NavigationDestination(
      icon: Text(emoji, style: const TextStyle(fontSize: 20)),
      label: label,
    );
