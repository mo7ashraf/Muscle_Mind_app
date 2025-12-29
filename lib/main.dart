import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'features/auth/providers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/trainee/screens/trainee_dashboard_screen.dart';
import 'features/trainer/screens/trainer_dashboard_screen.dart';

// Phase 2
import 'features/progress/screens/add_measurement_screen.dart';
import 'features/progress/screens/add_progress_screen.dart';
import 'features/progress/screens/progress_screen.dart';
import 'features/diet/screens/add_meal_screen.dart';
import 'features/diet/screens/create_diet_plan_screen.dart';
import 'features/diet/screens/diet_plan_details_screen.dart';
import 'features/diet/screens/diet_plans_screen.dart';
import 'features/workouts/screens/add_exercise_screen.dart';
import 'features/workouts/screens/create_workout_screen.dart';
import 'features/workouts/screens/workout_details_screen.dart';
import 'features/workouts/screens/workouts_screen.dart';

void main() {
  runApp(const ProviderScope(child: MuscleMindApp()));
}

class MuscleMindApp extends ConsumerWidget {
  const MuscleMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MUSCLE & MIND',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.trainerHome: (_) => const TrainerDashboardScreen(),
        AppRoutes.traineeHome: (_) => const TraineeDashboardScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),

        // Phase 2 (simple routes)
        AppRoutes.progress: (_) => const ProgressScreen(),
        AppRoutes.addProgress: (_) => const AddProgressScreen(),
        AppRoutes.addMeasurement: (_) => const AddMeasurementScreen(),
        AppRoutes.dietPlans: (_) => const DietPlansScreen(),
        AppRoutes.createDietPlan: (_) => const CreateDietPlanScreen(),

        // Workouts
        AppRoutes.workouts: (_) => const WorkoutsScreen(),
        AppRoutes.createWorkout: (_) => const CreateWorkoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.dietPlanDetails) {
          final id = settings.arguments;
          if (id is int) {
            return MaterialPageRoute(builder: (_) => DietPlanDetailsScreen(dietPlanId: id));
          }
        }
        if (settings.name == AppRoutes.addMeal) {
          final id = settings.arguments;
          if (id is int) {
            return MaterialPageRoute(builder: (_) => AddMealScreen(dietPlanId: id));
          }
        }
        if (settings.name == AppRoutes.workoutDetails) {
          final id = settings.arguments;
          if (id is int) {
            return MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workoutId: id));
          }
        }
        if (settings.name == AppRoutes.addExercise) {
          final id = settings.arguments;
          if (id is int) {
            return MaterialPageRoute(builder: (_) => AddExerciseScreen(workoutId: id));
          }
        }

        return null;
      },
      home: auth.isLoading
          ? const SplashScreen()
          : auth.isAuthed
              ? (auth.user!.role == 'trainer'
                  ? const TrainerDashboardScreen()
                  : const TraineeDashboardScreen())
              : const LoginScreen(),
    );
  }
}