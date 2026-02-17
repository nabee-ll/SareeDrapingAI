import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/store_provider.dart';
import 'services/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
