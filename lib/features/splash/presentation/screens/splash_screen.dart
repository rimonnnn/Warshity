// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/routing/router_generator_config.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/splash/widgets/loading_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.locale});
  final Locale? locale;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (widget.locale != null) {
        await context.setLocale(widget.locale!);
      }

      if (!mounted) return;

      _navigateNext();
    });
  }

  /// Splash stays visible until BOTH the intro animation and the Firebase
  /// session answer are ready, so protected pages are never built before the
  /// auth state is known (reload, cleared site data, direct deep link...).
  Future<void> _navigateNext() async {
    try {
      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 2500)),
        getIt<AuthCubit>().sessionReady,
      ]);

      if (!mounted) return;

      final hasSeenOnboarding = getIt<OnboardingLocalDataSource>().isCompleted();

      if (!hasSeenOnboarding) {
        // First run wins over the restored location.
        RouterGeneratorConfig.consumePendingLocation();
        context.go(AppRoutes.onboarding);
        return;
      }

      // Location requested before the session was known (deep link/reload).
      final pendingLocation = RouterGeneratorConfig.consumePendingLocation();

      if (pendingLocation != null) {
        // The router guard validates it: protected routes bounce to login
        // when there is no user, auth routes bounce to main when there is.
        context.go(pendingLocation);
        return;
      }

      final isLoggedIn = getIt<AuthRepo>().currentUser != null;

      context.go(isLoggedIn ? AppRoutes.mainScreen : AppRoutes.loginScreen);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[splash] navigation failed: $error\n$stackTrace');
      }

      if (!mounted) return;

      // Safe fallback: the router guard redirects to main if a user exists.
      RouterGeneratorConfig.consumePendingLocation();
      context.go(AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      messageKey: 'loading_preparing',
      animateIntro: true,
    );
  }
}
