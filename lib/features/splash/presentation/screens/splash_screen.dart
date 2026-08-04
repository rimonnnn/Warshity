// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_duration.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/splash/widgets/circel_progress_indecator.dart';
import 'package:warshity/features/splash/widgets/logo_widget.dart';
import 'package:warshity/features/splash/widgets/text_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateNext();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
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

      // لو فيه مستخدم متسجل دخول بالفعل (Firebase بيتذكره تلقائيًا)
      // نوديه على home على طول، من غير ما نعرضله شاشة اللوجين تاني
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoWidget(),
                    HeightSpace(43),
                    TextWidget(textKey: 'wershity'),
                    HeightSpace(200),
                    _buildLoadingIndicator(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return CircelProgressIndecator();
  }
}
