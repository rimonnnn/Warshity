import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/helper/app_validators.dart';

import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Login action', () {
    testWidgets('calls authRepo.login once with the entered credentials', (
      tester,
    ) async {
      // Sanity check: the valid values really pass the validators.
      expect(AppValidators.email(validEmail), isNull);
      expect(AppValidators.password(validPassword), isNull);

      await h.pumpLogin(tester);

      await h.fillValidForm(tester);
      await tapVisible(tester, loginButton);

      verify(
        h.authRepo.login(email: validEmail, password: validPassword),
      ).called(1);

      await flushSnackBar(tester); // LoginSuccess → snackbar + navigation
    });

    testWidgets('trims email and password before submitting', (tester) async {
      await h.pumpLogin(tester);

      await tester.enterText(emailField, '  $validEmail  ');
      await tester.enterText(passwordField, '  $validPassword  ');
      await tapVisible(tester, loginButton);

      verify(
        h.authRepo.login(email: validEmail, password: validPassword),
      ).called(1);

      await flushSnackBar(tester);
    });
  });

  group('LoginMobileLayout | Social sign-in', () {
    testWidgets('Google button calls signInWithGoogle', (tester) async {
      await h.pumpLogin(tester);

      await tapVisible(tester, socialButtons.at(0));

      verify(h.authRepo.signInWithGoogle()).called(1);
      verifyNever(h.authRepo.signInWithFacebook());

      await flushSnackBar(tester);
    });

    testWidgets('Facebook button calls signInWithFacebook', (tester) async {
      await h.pumpLogin(tester);

      await tapVisible(tester, socialButtons.at(1));

      verify(h.authRepo.signInWithFacebook()).called(1);
      verifyNever(h.authRepo.signInWithGoogle());

      await flushSnackBar(tester);
    });
  });
}