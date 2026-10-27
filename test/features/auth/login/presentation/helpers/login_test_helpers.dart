import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_mobile_layout.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_web_layout.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

import '../../../cubit/auth_mocks.mocks.dart';

// Re-exported so test files can use MockUserCredential without another import.
export '../../../cubit/auth_mocks.mocks.dart';

// ───────────────────────── Constants ─────────────────────────

const mainMarker = 'MAIN_SCREEN_MARKER';
const forgetMarker = 'FORGET_SCREEN_MARKER';
const registerMarker = 'REGISTER_SCREEN_MARKER';

const validEmail = 'test@example.com';
const validPassword = 'Test@1234';

// ───────────────────────── Finders ─────────────────────────
// If the inner widgets change, update the finders here only.

final emailField = find.byType(TextFormField).at(0);
final passwordField = find.byType(TextFormField).at(1);
final loginButton = find.byType(PrimaryButtonWidget);
final socialButtons = find.byType(OutlinedButtonWidget);

// ───────────────────────── Helpers ─────────────────────────

/// Returns an empty map, so `.tr()` returns the key itself
/// and we can use `find.text('welcome')`.
class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

/// Mirrors the routes in RouterGeneratorConfig (path = name = AppRoutes.x).
/// Real screens are replaced by placeholders to avoid getIt and Firebase.
GoRouter _buildRouter(Widget layout) => GoRouter(
  initialLocation: AppRoutes.loginScreen,
  routes: [
    GoRoute(
      path: AppRoutes.loginScreen,
      name: AppRoutes.loginScreen,
      builder: (_, _) => layout,
    ),
    GoRoute(
      path: AppRoutes.mainScreen,
      name: AppRoutes.mainScreen,
      builder: (_, _) => const Scaffold(body: Text(mainMarker)),
    ),
    GoRoute(
      path: AppRoutes.forgetPassScreen,
      name: AppRoutes.forgetPassScreen,
      builder: (_, _) => const Scaffold(body: Text(forgetMarker)),
    ),
    GoRoute(
      path: AppRoutes.registerScreen,
      name: AppRoutes.registerScreen,
      builder: (_, _) => const Scaffold(body: Text(registerMarker)),
    ),
  ],
);

/// Call from `setUpAll` in every test file.
Future<void> setUpLoginTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

/// Returns the validator's error message for [input] and fails the test
/// if the validator accepts it.
String errorOf(String? Function(String?) validator, String input) {
  final error = validator(input);
  expect(
    error,
    isNotNull,
    reason:
        'The validator should reject "$input". '
        'Adjust the value if your rules are different.',
  );
  return error!;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Advances time until the snackbar and its timers are gone, so the test
/// does not end with a pending Timer. The snackbar creates a ~6s dismiss
/// timer when it is built: each 7s pump finishes any timer created in the
/// previous one, and the extra pumps complete the hide animation.
Future<void> flushSnackBar(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(seconds: 7));
  }
}

/// Creates the mocked repos and the real [AuthCubit] for one test.
/// Create it inside `setUp`.
class LoginTestHarness {
  LoginTestHarness() {
    authRepo = MockAuthRepo();
    registerRepo = MockRegisterRepo();

    // AuthCubit subscribes to watchUserData in its constructor.
    when(
      authRepo.watchUserData(),
    ).thenAnswer((_) => const Stream<UserModel?>.empty());

    // AuthCubit also listens to the session stream in its constructor.
    when(
      authRepo.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    when(
      authRepo.login(email: anyNamed('email'), password: anyNamed('password')),
    ).thenAnswer((_) async => MockUserCredential());
    when(
      authRepo.signInWithGoogle(),
    ).thenAnswer((_) async => MockUserCredential());
    when(
      authRepo.signInWithFacebook(),
    ).thenAnswer((_) async => MockUserCredential());

    cubit = AuthCubit(registerRepo, authRepo);
    addTearDown(cubit.close);
  }

  late final MockAuthRepo authRepo;
  late final MockRegisterRepo registerRepo;
  late final AuthCubit cubit;

  /// Pumps the login screen. Defaults to the mobile layout on a 390x844 phone.
  ///
  /// [extraProviders] are added next to the AuthCubit provider, for widgets
  /// that read other blocs (for example a settings widget needing ThemeCubit).
  Future<void> pumpLogin(
    WidgetTester tester, {
    Widget layout = const LoginMobileLayout(),
    Size logicalSize = const Size(390, 844),
    double pixelRatio = 3.0,
    List<BlocProvider<StateStreamableSource<Object?>>> extraProviders =
        const [],
  }) async {
    tester.view.physicalSize = logicalSize * pixelRatio;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);

    final router = _buildRouter(layout);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        path: 'unused',
        assetLoader: const _KeysAssetLoader(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: cubit),
            ...extraProviders,
          ],
          // designSize == logicalSize → `.w` / `.h` are 1:1 (fixed pixels),
          // which matches how the web layout is meant to render.
          child: ScreenUtilInit(
            designSize: logicalSize,
            builder: (context, _) => MaterialApp.router(
              routerConfig: router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              theme: ThemeData(useMaterial3: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps the web layout on a 1440x900 desktop viewport.
  Future<void> pumpWebLogin(
    WidgetTester tester, {
    List<BlocProvider<StateStreamableSource<Object?>>> extraProviders =
        const [],
  }) => pumpLogin(
    tester,
    layout: const LoginWebLayout(),
    logicalSize: const Size(1440, 900),
    pixelRatio: 1.0,
    extraProviders: extraProviders,
  );

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(emailField, validEmail);
    await tester.enterText(passwordField, validPassword);
  }

  /// Makes authRepo.login hang until the returned completer is completed,
  /// so the cubit stays in AuthLoading.
  Future<Completer<UserCredential>> startLoading(WidgetTester tester) async {
    final completer = Completer<UserCredential>();
    when(
      authRepo.login(email: anyNamed('email'), password: anyNamed('password')),
    ).thenAnswer((_) => completer.future);

    await fillValidForm(tester);
    await tapVisible(tester, loginButton);
    return completer;
  }

  void verifyLoginNeverCalled() => verifyNever(
    authRepo.login(email: anyNamed('email'), password: anyNamed('password')),
  );
}
