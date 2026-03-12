import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  DateTime? _lastBackPress;

  Future<bool> _onWillPop() async {
    // If not on the Home tab, go back to Home tab first
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);
      return false;
    }
    // Double-back-to-exit on home tab
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
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
              selectedIcon:
                  Icon(Icons.checkroom, color: AppColors.primaryLight),
              label: AppStrings.myDrapes,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: AppColors.textHint),
              selectedIcon: Icon(Icons.person, color: AppColors.primaryLight),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
