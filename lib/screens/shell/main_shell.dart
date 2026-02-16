import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textHint),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryLight),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: AppColors.textHint),
            selectedIcon: Icon(Icons.explore, color: AppColors.primaryLight),
            label: AppStrings.explore,
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined, color: AppColors.textHint),
            selectedIcon: Icon(Icons.checkroom, color: AppColors.primaryLight),
            label: AppStrings.myDrapes,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined, color: AppColors.textHint),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryLight),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}
