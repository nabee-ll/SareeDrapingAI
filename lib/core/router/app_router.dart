import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_draping_app/models/saree_asset_model.dart';
import 'package:saree_draping_app/screens/auth/login_screen.dart';
import 'package:saree_draping_app/screens/auth/register_screen.dart';
import 'package:saree_draping_app/screens/credits/credits_screen.dart';
import 'package:saree_draping_app/screens/draping/virtual_draping_screen.dart';
import 'package:saree_draping_app/screens/explore/explore_screen.dart';
import 'package:saree_draping_app/screens/home/home_screen.dart';
import 'package:saree_draping_app/screens/my_drapes/my_drapes_screen.dart';
import 'package:saree_draping_app/screens/onboarding/onboarding_screen.dart';
import 'package:saree_draping_app/screens/profile/profile_screen.dart';
import 'package:saree_draping_app/screens/shell/main_shell.dart';
import 'package:saree_draping_app/screens/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main app shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'virtual-draping',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final asset = state.extra as SareeAsset?;
                    return VirtualDrapingScreen(preselectedAsset: asset);
                  },
                ),
                GoRoute(
                  path: 'credits',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreditsScreen(),
                ),
              ],
            ),
          ],
        ),

        // Explore / Catalogue branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),

        // My Drapes / Gallery branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-drapes',
              builder: (context, state) => const MyDrapesScreen(),
            ),
          ],
        ),

        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
