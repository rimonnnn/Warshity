import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/auth/login/presentation/screens/login_screen.dart';
import 'package:warshity/features/home/presentation/screens/home_screen.dart';
import 'package:warshity/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:warshity/features/splash/presentation/screens/splash_screen.dart';

class RouterGeneratorConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    errorBuilder: (context, state) => const NotFoundScreen(),

    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeScreen,
        name: AppRoutes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Page not found")));
  }
}
