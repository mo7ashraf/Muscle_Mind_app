import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/trainer/screens/trainer_dashboard_screen.dart';
import 'features/trainee/screens/trainee_dashboard_screen.dart';
import 'features/common/screens/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MuscleMindApp()));
}

class MuscleMindApp extends StatelessWidget {
  const MuscleMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.trainerHome: (_) => const TrainerDashboardScreen(),
        AppRoutes.traineeHome: (_) => const TraineeDashboardScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
