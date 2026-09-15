import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/services/shared_pref_service.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

import 'core/di/injection.dart';
import 'core/routing/router_generator_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'core/theme/cubit/theme_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: '3471398589689215',
      cookie: true,
      xfbml: true,
      version: 'v23.0',
    );
  }

  await Supabase.initialize(
    url: 'https://jcyynfpomdtlyrnrmrng.supabase.co',
    publishableKey: 'sb_publishable_wc2dfa0re-gDJ23MJw7hTA_QdWZxwNj',
  );

  await EasyLocalization.ensureInitialized();
  await SharedPrefService.init();
  await setupDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppAssets.translations,
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _showMessageThenSplash({
    required BuildContext context,
    required String message,
    required AnimatedSnackBarType type,
  }) async {
    showAnimatedSnackDialog(context, message: message, type: type);

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!context.mounted) {
      return;
    }

    context.goNamed(AppRoutes.splashScreen);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(getIt())),
       BlocProvider<AccountSharingCubit>(
  create: (_) =>
      getIt<AccountSharingCubit>()..startWatchingSharedAccounts(),
),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 884),
        minTextAdapt: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BlocListener<AccountSharingCubit, AccountSharingState>(
                listener: (context, state) {
                  if (state is AccountInvitationAccepted) {
                    context.goNamed(AppRoutes.splashScreen);
                    return;
                  }

                  if (state is AccountInvitationRejected) {
                    return;
                  }

                  if (state is AccountSharedAccountDeleted) {
                    context.goNamed(AppRoutes.splashScreen);
                    return;
                  }

                  if (state is AccountInvitationAcceptedRemotely) {
                    unawaited(
                      _showMessageThenSplash(
                        context: context,
                        message: 'invitation_accepted'.tr(),
                        type: AnimatedSnackBarType.success,
                      ),
                    );
                    return;
                  }

                  if (state is AccountInvitationRejectedRemotely) {
                    showAnimatedSnackDialog(
                      context,
                      message: 'invitation_rejected'.tr(),
                      type: AnimatedSnackBarType.error,
                    );
                    return;
                  }

                  if (state is AccountSharedAccountDeletedRemotely) {
                    unawaited(
                      _showMessageThenSplash(
                        context: context,
                        message: 'shared_account_deleted'.tr(),
                        type: AnimatedSnackBarType.error,
                      ),
                    );
                    return;
                  }
                },
                child: MaterialApp.router(
                  title: 'Masiter',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  routerConfig: RouterGeneratorConfig.goRouter,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
