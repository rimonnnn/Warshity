import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/web_settings_actions.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_web_layout.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';

import '../helpers/login_test_helpers.dart';

/// Only what is specific to the web layout.
/// Validation, social buttons, password toggle and navigation are covered by
/// the mobile tests and the AuthCubit unit tests.
void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  final rememberMeCheckbox = find.descendant(
    of: find.byType(CheckboxWidget),
    matching: find.byType(Checkbox),
  );

  bool isChecked(WidgetTester tester) =>
      tester.widget<CheckboxWidget>(find.byType(CheckboxWidget)).value;

  group('LoginWebLayout | Rendering', () {
    testWidgets('shows the web-only elements next to the form', (tester) async {
      await h.pumpWebLogin(tester);

      expect(find.byType(LoginWebLayout), findsOneWidget);
      expect(find.text('welcome'), findsOneWidget);
      expect(find.text('startlogin'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('remember_me'), findsOneWidget);
      expect(find.byType(CheckboxWidget), findsOneWidget);
      expect(find.text('forget'), findsOneWidget);
      expect(loginButton, findsOneWidget);
      expect(socialButtons, findsNWidgets(2));
      expect(find.byType(FooterWidget), findsOneWidget);
      expect(find.byType(WebSettingsActions), findsOneWidget);
    });

    testWidgets('keeps the login card at most 550px wide on a wide screen', (
      tester,
    ) async {
      await h.pumpWebLogin(tester);

      final cardWidth = tester.getSize(find.byType(Form)).width;

      expect(cardWidth, greaterThan(0));
      expect(cardWidth, lessThanOrEqualTo(550));
    });
  });

  group('LoginWebLayout | Remember me', () {
    testWidgets('starts unchecked', (tester) async {
      await h.pumpWebLogin(tester);

      expect(isChecked(tester), isFalse);
    });

    testWidgets('toggles when the checkbox is tapped', (tester) async {
      await h.pumpWebLogin(tester);

      await tapVisible(tester, rememberMeCheckbox);
      expect(isChecked(tester), isTrue);

      await tapVisible(tester, rememberMeCheckbox);
      expect(isChecked(tester), isFalse);
    });
  });
}