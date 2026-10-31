import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/routing/router_generator_config.dart';
import 'package:warshity/core/services/app_update_service.dart';
import 'package:warshity/core/widgets/app_update_dialog.dart';
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

  /// Resolves the session and navigates to the correct screen.
  ///
  /// The update check runs in parallel with the splash delay and
  /// Firebase session restoration.
  Future<void> _navigateNext() async {
    try {
      final hasSeenOnboarding = getIt<OnboardingLocalDataSource>()
          .isCompleted();

      // Do not interrupt the first-run onboarding experience.
      final Future<AppUpdateInfo?> updateFuture = hasSeenOnboarding
          ? _checkForAvailableUpdate()
          : Future<AppUpdateInfo?>.value(null);

      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 2500)),
        getIt<AuthCubit>().sessionReady,
      ]);

      if (!mounted) return;

      if (!hasSeenOnboarding) {
        RouterGeneratorConfig.consumePendingLocation();

        context.go(AppRoutes.onboarding);
        return;
      }

      // Restore the original location requested before the session
      // was resolved, if one exists.
      final pendingLocation = RouterGeneratorConfig.consumePendingLocation();

      if (pendingLocation != null) {
        context.go(pendingLocation);

        await _showUpdateAfterNavigation(updateFuture);
        return;
      }

      final isLoggedIn = getIt<AuthRepo>().currentUser != null;

      context.go(isLoggedIn ? AppRoutes.mainScreen : AppRoutes.loginScreen);

      await _showUpdateAfterNavigation(updateFuture);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[splash] navigation failed: $error\n$stackTrace');
      }

      if (!mounted) return;

      RouterGeneratorConfig.consumePendingLocation();
      context.go(AppRoutes.loginScreen);
    }
  }

  /// Checks for updates on Android only.
  ///
  /// Update-check failures should never prevent the app from opening.
  Future<AppUpdateInfo?> _checkForAvailableUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    try {
      return await AppUpdateService().checkForUpdate();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[app-update] check failed: $error\n$stackTrace');
      }

      return null;
    }
  }

  /// Shows the update dialog after GoRouter has completed navigation.
  ///
  /// Uses the root navigator because this SplashScreen may already
  /// have been disposed after calling context.go().
  Future<void> _showUpdateAfterNavigation(
    Future<AppUpdateInfo?> updateFuture,
  ) async {
    try {
      final update = await updateFuture;

      if (update == null) return;

      // Wait until the destination route has been rendered.
      await WidgetsBinding.instance.endOfFrame;

      final navigatorContext =
          RouterGeneratorConfig.rootNavigatorKey.currentContext;

      if (navigatorContext == null || !navigatorContext.mounted) {
        return;
      }

      await showAppUpdateDialog(navigatorContext, update);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[app-update] dialog failed: $error\n$stackTrace');
      }
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
