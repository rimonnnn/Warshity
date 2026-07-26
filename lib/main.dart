import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/services/shared_pref_service.dart';
import 'package:warshity/core/styling/app_assets.dart';

import 'core/di/injection.dart';
import 'core/routing/router_generator_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPrefService.init();

  await setupDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('ar')],
      path: AppAssets.translations,
      fallbackLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(getIt()),
      child: ScreenUtilInit(
        designSize: const Size(390, 884),
        minTextAdapt: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'warshity',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state.themeMode,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                routerConfig: RouterGeneratorConfig.goRouter,
              );
            },
          );
        },
      ),
    );
  }
}
