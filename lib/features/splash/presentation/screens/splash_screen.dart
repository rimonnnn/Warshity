// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  const SplashScreen({super.key, this.locale});
  final Locale? locale;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo: scale + fade (0.0 -> 0.5 of the timeline)
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // Title text: fade + slide up (0.3 -> 0.7)
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  // Subtitle text: fade + slide up (0.45 -> 0.85), starts slightly after title
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  // Loading indicator: fade in last (0.7 -> 1.0)
  late Animation<double> _loadingFade;

 @override
void initState() {
  super.initState();

  _initAnimations();

  _controller.forward();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    if (widget.locale != null) {
      await context.setLocale(widget.locale!);
    }

    if (!mounted) return;

    _navigateNext();
  });
}

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
      ),
    );

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: LogoWidget(),
                  ),
                ),
                HeightSpace(43),
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: TextWidget(textKey: 'masiter'.tr()),
                  ),
                ),
                HeightSpace(16),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: TextWidget(
                      textKey: 'your_buddiness_under_controle'.tr(),
                      style: context.text.bodyLarge,
                    ),
                  ),
                ),
                HeightSpace(200),
                FadeTransition(
                  opacity: _loadingFade,
                  child: _buildLoadingIndicator(context),
                ),
              ],
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
