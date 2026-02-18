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
import 'providers/onboarding_provider.dart';
import 'providers/store_provider.dart';
import 'services/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed Firestore with initial data (runs only once)
  await DataSeeder().seedIfNeeded();

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
            if (auth.isAuthenticated && auth.user?.id != null) {
              provider.loadForUser(auth.user!.id!);
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
