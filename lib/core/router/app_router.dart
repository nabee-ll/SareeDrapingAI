import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_draping_app/screens/credits/credits_screen.dart';
import 'package:saree_draping_app/screens/auth/login_screen.dart';
import 'package:saree_draping_app/screens/auth/register_screen.dart';
import 'package:saree_draping_app/screens/business/add_store_screen.dart';
import 'package:saree_draping_app/screens/business/business_dashboard_screen.dart';
import 'package:saree_draping_app/screens/business/design_patterns_screen.dart';
import 'package:saree_draping_app/screens/business/vsd_upload_screen.dart';
import 'package:saree_draping_app/screens/draping/virtual_draping_screen.dart';
import 'package:saree_draping_app/screens/explore/explore_screen.dart';
import 'package:saree_draping_app/screens/home/home_screen.dart';
import 'package:saree_draping_app/screens/my_drapes/my_drapes_screen.dart';
import 'package:saree_draping_app/screens/onboarding/onboarding_screen.dart';
import 'package:saree_draping_app/screens/profile/profile_screen.dart';
import 'package:saree_draping_app/screens/shell/main_shell.dart';
import 'package:saree_draping_app/screens/splash/splash_screen.dart';
import 'package:saree_draping_app/screens/styles/regional_styles_screen.dart';
import 'package:saree_draping_app/screens/subscription/subscription_screen.dart';
import 'package:saree_draping_app/screens/tutorials/tutorials_screen.dart';

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
                  path: 'tutorials',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const TutorialsScreen(),
                ),
                GoRoute(
                  path: 'styles',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const RegionalStylesScreen(),
                ),
                GoRoute(
                  path: 'subscriptions',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SubscriptionScreen(),
                ),
                GoRoute(
                  path: 'virtual-draping',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const VirtualDrapingScreen(),
                ),
                GoRoute(
                  path: 'credits',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreditsScreen(),
                ),
                GoRoute(
                  path: 'business',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const BusinessDashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'designs',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          const DesignPatternsScreen(),
                    ),
                    GoRoute(
                      path: 'add-store',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const AddStoreScreen(),
                    ),
                    GoRoute(
                      path: 'add-design',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          const DesignPatternsScreen(),
                    ),
                    GoRoute(
                      path: 'vsd-upload',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          const VsdUploadScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Explore branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        // My Drapes branch
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
