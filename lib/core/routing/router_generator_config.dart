import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/auth/access_password/presentation/screens/access_pass_screen.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/forget_password/presentation/screens/forget_pass_screen.dart';
import 'package:warshity/features/auth/login/presentation/screens/login_screen.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/presentation/screens/register_screen.dart';
import 'package:warshity/features/home/presentation/screens/home_screen.dart';
import 'package:warshity/features/invoices/presentation/screens/invoice_screen.dart';
import 'package:warshity/features/main/presentation/screens/main_screen.dart';
import 'package:warshity/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:warshity/features/splash/presentation/screens/splash_screen.dart';

class RouterGeneratorConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: kIsWeb ? AppRoutes.loginScreen : AppRoutes.splashScreen,
    errorBuilder: (context, state) => const NotFoundScreen(),

    redirect: (context, state) {
      final isLoggedIn = getIt<AuthRepo>().currentUser != null;
      final isGoingToAuthScreen =
          state.matchedLocation == AppRoutes.loginScreen ||
          state.matchedLocation == AppRoutes.registerScreen ||
          state.matchedLocation == AppRoutes.forgetPassScreen ||
          state.matchedLocation == AppRoutes.accessPassScreen;

      // لو متسجل دخول بالفعل وبيحاول يروح لصفحة auth (زي login)
      // نوديه على home بدل ما نعرضله اللوجين تاني
      if (isLoggedIn && isGoingToAuthScreen) {
        return AppRoutes.mainScreen;
      }

      return null; // من غير تحويل، كمل عادي
    },
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
        path: AppRoutes.homeScreen,
        name: AppRoutes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.mainScreen,
        name: AppRoutes.mainScreen,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoiceScreen,
        name: AppRoutes.invoiceScreen,
        builder: (context, state) => const InvoiceScreen(),
      ),

      // كل شاشات الـ Auth بتتشارك في نفس الـ AuthCubit instance
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) =>
                AuthCubit(getIt<RegisterRepo>(), getIt<AuthRepo>()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.loginScreen,
            name: AppRoutes.loginScreen,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.registerScreen,
            name: AppRoutes.registerScreen,
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: AppRoutes.forgetPassScreen,
            name: AppRoutes.forgetPassScreen,
            builder: (context, state) => const ForgetPassScreen(),
          ),
          GoRoute(
            path: AppRoutes.accessPassScreen,
            name: AppRoutes.accessPassScreen,
            builder: (context, state) {
              final email = state.extra as String? ?? "";

              return AccessPassScreen(email: email);
            },
          ),
        ],
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
