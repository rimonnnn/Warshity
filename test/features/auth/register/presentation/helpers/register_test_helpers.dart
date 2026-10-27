import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:warshity/features/auth/register/data/models/user_model.dart';
// TODO: adjust this path to where RegisterMobileLayout lives in your project
import 'package:warshity/features/auth/register/presentation/layout/register_mobile_layout.dart';

import '../../../cubit/auth_mocks.mocks.dart';

// Re-exported so test files can use the mocks without another import.
export '../../../cubit/auth_mocks.mocks.dart';

// ───────────────────────── Constants ─────────────────────────

const loginMarker = 'LOGIN_SCREEN_MARKER';

const validShopName = 'My Workshop';
const validOwnerName = 'Rimon';
const validEmail = 'test@example.com';
const validPassword = 'Test@1234';

/// With empty translations `.tr()` returns the key, so this is the item text.
const validActivity = 'activities.plumbing';

// ───────────────────────── Finders ─────────────────────────
// If the inner widgets change, update the finders here only.
// TextFormField order in the layout: shop, owner, email, password, confirm
// (the activity dropdown is a DropdownSearch, not a TextFormField).

final shopNameField = find.byType(TextFormField).at(0);
final ownerNameField = find.byType(TextFormField).at(1);
final emailField = find.byType(TextFormField).at(2);
final passwordField = find.byType(TextFormField).at(3);
final confirmPasswordField = find.byType(TextFormField).at(4);
final activityDropdown = find.byType(DropdownSearch<String>);
final termsCheckbox = find.byType(Checkbox);
final createAccountButton = find.byType(PrimaryButtonWidget);
final socialButtons = find.byType(OutlinedButtonWidget);

// ───────────────────────── Helpers ─────────────────────────

/// Keeps translations empty, so `.tr()` returns the key itself, except for the
/// keys below.
///
/// The test font (Ahem) draws every character as a full-size square, so long
/// keys are much wider than real text. Keys that sit in fixed-width widgets
/// are shortened here to avoid overflow errors that only exist in tests.
class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      const <String, dynamic>{
        // Register button label (inside a 310px button with an icon).
        'create_account1': 'Create',
      };
}

/// Register route + a placeholder login route (the footer navigates to it).
GoRouter _buildRouter() => GoRouter(
  initialLocation: AppRoutes.registerScreen,
  routes: [
    GoRoute(
      path: AppRoutes.registerScreen,
      name: AppRoutes.registerScreen,
      builder: (_, __) => const RegisterMobileLayout(),
    ),
    GoRoute(
      path: AppRoutes.loginScreen,
      name: AppRoutes.loginScreen,
      builder: (_, __) => const Scaffold(body: Text(loginMarker)),
    ),
  ],
);

/// Call from `setUpAll` in every test file.
Future<void> setUpRegisterTestEnvironment() async {
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

/// Advances time until snackbars and their timers are gone, so the test does
/// not end with a pending Timer (each pump is longer than the ~6s dismiss
/// timer of the animated snackbar).
Future<void> flushSnackBar(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(seconds: 7));
  }
}

/// Creates the mocked repos and the real [AuthCubit] for one test.
/// Create it inside `setUp`.
class RegisterTestHarness {
  RegisterTestHarness() {
    authRepo = MockAuthRepo();
    registerRepo = MockRegisterRepo();

    // AuthCubit subscribes to watchUserData in its constructor.
    when(
      authRepo.watchUserData(),
    ).thenAnswer((_) => const Stream<UserModel?>.empty());

    // The layout reads cubit.categoriesStream in initState.
    when(
      registerRepo.watchCategories(),
    ).thenAnswer((_) => const Stream<List<String>>.empty());

    when(
      registerRepo.register(
        user: anyNamed('user'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async {});
    when(registerRepo.resendEmailVerification()).thenAnswer((_) async {});

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

  /// Pumps the register screen on a 390x844 phone.
  /// [firestoreCategories] is what the categories stream emits.
  Future<void> pumpRegister(
    WidgetTester tester, {
    List<String> firestoreCategories = const [],
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    when(
      registerRepo.watchCategories(),
    ).thenAnswer((_) => Stream<List<String>>.value(firestoreCategories));

    final router = _buildRouter();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        path: 'unused',
        assetLoader: const _KeysAssetLoader(),
        child: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
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

  /// Fills the five text fields. The confirm field defaults to [password].
  Future<void> fillTextFields(
    WidgetTester tester, {
    String shopName = validShopName,
    String ownerName = validOwnerName,
    String email = validEmail,
    String password = validPassword,
    String? confirmPassword,
  }) async {
    await tester.enterText(shopNameField, shopName);
    await tester.enterText(ownerNameField, ownerName);
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.enterText(confirmPasswordField, confirmPassword ?? password);
  }

  Future<void> openActivityDropdown(WidgetTester tester) async {
    await tapVisible(tester, activityDropdown);
    await tester.pumpAndSettle();
  }

  Future<void> selectActivity(
    WidgetTester tester, [
    String activity = validActivity,
  ]) async {
    await openActivityDropdown(tester);
    // The popup items ignore pointer events on the text itself (the row
    // handles the tap), so the "would not hit test" warning is expected.
    await tester.tap(find.text(activity), warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> acceptTerms(WidgetTester tester) =>
      tapVisible(tester, termsCheckbox);

  /// Valid text fields + an activity + accepted terms.
  Future<void> fillValidForm(WidgetTester tester) async {
    await fillTextFields(tester);
    await selectActivity(tester);
    await acceptTerms(tester);
  }

  Future<void> submit(WidgetTester tester) =>
      tapVisible(tester, createAccountButton);

  void verifyRegisterNeverCalled() => verifyNever(
    registerRepo.register(
      user: anyNamed('user'),
      password: anyNamed('password'),
    ),
  );
}
