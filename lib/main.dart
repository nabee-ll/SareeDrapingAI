import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/catalogue_provider.dart';
import 'providers/credit_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/job_provider.dart';
import 'providers/onboarding_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DrapeAndGlowApp());
}

class DrapeAndGlowApp extends StatelessWidget {
  const DrapeAndGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CreditProvider>(
          create: (_) => CreditProvider(),
          update: (_, auth, credits) {
            final provider = credits ?? CreditProvider();
            if (auth.isAuthenticated) {
              provider.loadForUser();
            } else {
              provider.reset();
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
          create: (_) => JobProvider(),
          update: (_, auth, jobs) {
            final provider = jobs ?? JobProvider();
            if (!auth.isAuthenticated) provider.reset();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => CatalogueProvider()),
        ChangeNotifierProxyProvider<AuthProvider, GalleryProvider>(
          create: (_) => GalleryProvider(),
          update: (_, auth, gallery) {
            final provider = gallery ?? GalleryProvider();
            if (auth.isAuthenticated) {
              provider.load();
            } else {
              provider.reset();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) {
          final provider = OnboardingProvider();
          provider.loadOptions();
          return provider;
        }),
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
