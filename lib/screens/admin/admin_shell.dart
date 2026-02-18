import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final destinations = [
      _NavItem(icon: Icons.dashboard, label: 'Dashboard', path: '/admin'),
      _NavItem(icon: Icons.video_library, label: 'Videos', path: '/admin/videos'),
      _NavItem(icon: Icons.style, label: 'Styles', path: '/admin/styles'),
      _NavItem(icon: Icons.monetization_on, label: 'Credits', path: '/admin/credits'),
      _NavItem(icon: Icons.people, label: 'Users', path: '/admin/users'),
    ];

    int selectedIndex = 0;
    for (int i = destinations.length - 1; i >= 0; i--) {
      if (location.startsWith(destinations[i].path)) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimary,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'Admin Panel',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Exit Admin',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation rail for desktop / tablet
          if (MediaQuery.of(context).size.width >= 600)
            NavigationRail(
              backgroundColor: AppColors.secondaryLight,
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  context.go(destinations[i].path),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme:
                  const IconThemeData(color: AppColors.gold),
              selectedLabelTextStyle:
                  const TextStyle(color: AppColors.gold, fontSize: 12),
              unselectedIconTheme:
                  const IconThemeData(color: AppColors.textSecondary),
              unselectedLabelTextStyle: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
          Expanded(child: child),
        ],
      ),
      // Bottom nav for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
              backgroundColor: AppColors.secondaryLight,
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) =>
                  context.go(destinations[i].path),
              indicatorColor: AppColors.primary.withOpacity(0.3),
              destinations: destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon,
                            color: AppColors.textSecondary),
                        selectedIcon:
                            Icon(d.icon, color: AppColors.gold),
                        label: d.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(
      {required this.icon, required this.label, required this.path});
}
