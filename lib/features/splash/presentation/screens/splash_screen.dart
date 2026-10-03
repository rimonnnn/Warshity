// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
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

  void _navigateNext() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final hasSeenOnboarding = getIt<OnboardingLocalDataSource>()
          .isCompleted();

      if (!hasSeenOnboarding) {
        context.pushReplacementNamed(AppRoutes.onboarding);
        return;
      }

      final currentUser = getIt<AuthRepo>().currentUser;
      if (currentUser != null) {
        context.pushReplacementNamed(AppRoutes.mainScreen);
      } else {
        context.pushReplacementNamed(AppRoutes.loginScreen);
      }
    } catch (e, stackTrace) {
      debugPrint('Splash navigation error: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      messageKey: 'loading_preparing',
      animateIntro: false,
    );
  }
}
