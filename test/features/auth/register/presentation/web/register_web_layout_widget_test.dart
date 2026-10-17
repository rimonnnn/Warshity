import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/web_settings_actions.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/presentation/layout/register_web_layout.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';
import 'package:warshity/features/auth/register/presentation/widgets/custom_drobdown.dart';

import '../helpers/register_test_helpers.dart';

const _loginMarker = 'LOGIN_SCREEN_MARKER';

class _WebKeysAssetLoader extends AssetLoader {
  const _WebKeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      const <String, dynamic>{'create_account1': 'Create'};
}

GoRouter _buildWebRouter() => GoRouter(
  initialLocation: AppRoutes.registerScreen,
  routes: [
    GoRoute(
      path: AppRoutes.registerScreen,
      name: AppRoutes.registerScreen,
      builder: (_, __) => const RegisterWebLayout(),
    ),
    GoRoute(
      path: AppRoutes.loginScreen,
      name: AppRoutes.loginScreen,
      builder: (_, __) => const Scaffold(body: Text(_loginMarker)),
    ),
  ],
);

Future<void> _pumpRegisterWeb(
  WidgetTester tester,
  RegisterTestHarness h, {
  List<String> firestoreCategories = const <String>[],
}) async {
  // 1440x1000 logical pixels: exercise the desktop layout, not the mobile one.
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  when(h.registerRepo.watchCategories()).thenAnswer(
    (_) => Stream<List<String>>.value(firestoreCategories),
  );

  final router = _buildWebRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('en'), Locale('ar')],
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      path: 'unused',
      assetLoader: const _WebKeysAssetLoader(),
      child: BlocProvider<AuthCubit>.value(
        value: h.cubit,
        child: ScreenUtilInit(
          designSize: const Size(1440, 1000),
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

void _selectWebActivity(WidgetTester tester, [String activity = validActivity]) {
  final dropdown = tester.widget<CustomDropdown>(find.byType(CustomDropdown));
  // Invoke the public callback so this test targets form submission, not the
  // popup's pointer geometry. Popup interaction belongs in CustomDropdown's tests.
  dropdown.onSelected?.call(activity);
}

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() => h = RegisterTestHarness());

  group('RegisterWebLayout | Desktop-specific coverage', () {
    testWidgets('renders the desktop form and web settings actions', (
      tester,
    ) async {
      await _pumpRegisterWeb(tester, h);

      expect(find.byType(RegisterWebLayout), findsOneWidget);
      expect(find.byType(WebSettingsActions), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(CustomDropdown), findsOneWidget);
      expect(find.byType(CheckboxWidget), findsOneWidget);
      expect(find.byType(PrimaryButtonWidget), findsOneWidget);
      expect(find.byType(OutlinedButtonWidget), findsNWidgets(2));
      expect(find.byType(FooterWidget), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Desktop layout overflowed.');
    });

    testWidgets('passes merged, de-duplicated categories to CustomDropdown', (
      tester,
    ) async {
      await _pumpRegisterWeb(
        tester,
        h,
        firestoreCategories: const <String>[
          'Custom Category',
          'activities.carpentry',
          'Custom Category',
        ],
      );

      final dropdown = tester.widget<CustomDropdown>(find.byType(CustomDropdown));
      expect(dropdown.items, contains('Custom Category'));
      expect(
        dropdown.items.where((item) => item == 'activities.carpentry'),
        hasLength(1),
      );
      expect(
        dropdown.items.where((item) => item == 'Custom Category'),
        hasLength(1),
      );
    });

    testWidgets(
      'submits trimmed form data and clears the web form after registration',
      (tester) async {
        await _pumpRegisterWeb(tester, h);

        await h.fillTextFields(
          tester,
          shopName: '  $validShopName  ',
          ownerName: '  $validOwnerName  ',
          email: '  $validEmail  ',
          password: '  $validPassword  ',
        );
        _selectWebActivity(tester);
        await tester.pump();
        await h.acceptTerms(tester);
        await h.submit(tester);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        final verification = verify(
          h.registerRepo.register(
            user: captureAnyNamed('user'),
            password: captureAnyNamed('password'),
          ),
        );
        expect(verification.callCount, 1);

        final user = verification.captured[0] as UserModel;
        final password = verification.captured[1] as String;
        expect(user.shopName, validShopName);
        expect(user.ownerName, validOwnerName);
        expect(user.email, validEmail);
        expect(user.activity, validActivity);
        expect(password, validPassword);

        // RegisterWebLayout explicitly clears all five controllers on submit.
        for (var i = 0; i < 5; i++) {
          final editable = tester.widget<EditableText>(
            find.descendant(
              of: find.byType(TextFormField).at(i),
              matching: find.byType(EditableText),
            ),
          );
          expect(editable.controller.text, isEmpty, reason: 'field #$i');
        }

        await flushSnackBar(tester);
      },
    );

    testWidgets('requires terms acceptance before registering', (tester) async {
      await _pumpRegisterWeb(tester, h);

      await h.fillTextFields(tester);
      _selectWebActivity(tester);
      await tester.pump();
      // Intentionally do not tick the terms checkbox.
      await h.submit(tester);

      expect(find.text('validator_terms_required'), findsOneWidget);
      h.verifyRegisterNeverCalled();
      await flushSnackBar(tester);
    });

    testWidgets(
      'rejects a confirmation password that differs from the password',
      (tester) async {
        await _pumpRegisterWeb(tester, h);

        await h.fillTextFields(tester, confirmPassword: 'Different@1');
        _selectWebActivity(tester);
        await tester.pump();
        await h.acceptTerms(tester);
        await h.submit(tester);

        final mismatchMessage = AppValidators.confirmPassword(
          'Different@1',
          validPassword,
        );
        expect(mismatchMessage, isNotNull);
        expect(find.text(mismatchMessage!), findsOneWidget);
        h.verifyRegisterNeverCalled();
      },
    );
  });
}
