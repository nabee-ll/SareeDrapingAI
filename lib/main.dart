import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/credit_provider.dart';
import 'providers/data_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/store_provider.dart';
import 'services/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run seeder in background — never block app launch
  DataSeeder().seedIfNeeded().catchError((_) {});

  runApp(const SareeDrapingApp());
}

class SareeDrapingApp extends StatelessWidget {
  const SareeDrapingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CreditProvider>(
          create: (_) => CreditProvider(),
          update: (_, auth, credits) {
            final provider = credits ?? CreditProvider();
            final uid = auth.user?.id;
            if (auth.isAuthenticated && uid != null) {
              provider.loadForUser(uid); // idempotent — skips if already loaded
            } else if (!auth.isAuthenticated) {
              provider.reset(); // clear on logout
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) {
          final provider = DataProvider();
          provider.loadAll();
          return provider;
        }),
        ChangeNotifierProvider(create: (_) {
          final provider = OnboardingProvider();
          provider.loadOptions();
          return provider;
        }),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
