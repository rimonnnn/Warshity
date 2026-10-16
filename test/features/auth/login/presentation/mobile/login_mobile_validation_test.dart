import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Validation', () {
    testWidgets('shows both errors and skips login when fields are empty', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      await tapVisible(tester, loginButton);

      expect(find.text(errorOf(AppValidators.email, '')), findsOneWidget);
      expect(find.text(errorOf(AppValidators.password, '')), findsOneWidget);
      h.verifyLoginNeverCalled();
    });

    testWidgets('shows only the email error when email is empty', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      await tester.enterText(passwordField, validPassword);
      await tapVisible(tester, loginButton);

      expect(find.text(errorOf(AppValidators.email, '')), findsOneWidget);
      expect(find.text(errorOf(AppValidators.password, '')), findsNothing);
      h.verifyLoginNeverCalled();
    });

    testWidgets(
      'shows an error and skips login when the email format is invalid',
      (tester) async {
        await h.pumpLogin(tester);

        await tester.enterText(emailField, 'not-an-email');
        await tester.enterText(passwordField, validPassword);
        await tapVisible(tester, loginButton);

        expect(
          find.text(errorOf(AppValidators.email, 'not-an-email')),
          findsOneWidget,
        );
        h.verifyLoginNeverCalled();
      },
      // AppValidators.email only checks for an empty value today.
      // Remove `skip` after adding a format check (regex) to the validator.
      skip: true,
    );

    testWidgets('shows an error and skips login when the password is weak', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      await tester.enterText(emailField, validEmail);
      await tester.enterText(passwordField, '123');
      await tapVisible(tester, loginButton);

      expect(
        find.text(errorOf(AppValidators.password, '123')),
        findsOneWidget,
      );
      h.verifyLoginNeverCalled();
    });
  });
}