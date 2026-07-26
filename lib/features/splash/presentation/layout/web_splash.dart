// lib/features/splash/presentation/layouts/splash_web.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_duration.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/splash/widgets/logo_widget.dart';
import 'package:warshity/features/splash/widgets/text_widget.dart';

class WebSplash extends StatefulWidget {
  const WebSplash({super.key});

  @override
  State<WebSplash> createState() => _WebSplashState();
}

class _WebSplashState extends State<WebSplash>
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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  void _navigateNext() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      final hasSeenOnboarding = getIt<OnboardingLocalDataSource>()
          .isCompleted();

      context.pushReplacementNamed(
        hasSeenOnboarding ? AppRoutes.registerScreen : AppRoutes.onboarding,
      );
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.surface,
              context.colors.surfaceContainerHighest,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildCard(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: 440,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 48),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoWidget(width: 80, height: 80),
          const HeightSpace(28),
          const TextWidget(textKey: 'wershity'),
        ],
      ),
    );
  }
}
