import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_mobile_layout.dart';

import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Result states', () {
    testWidgets(
      'successful login shows a snackbar and navigates to the main screen',
      (tester) async {
        await h.pumpLogin(tester);

        await h.fillValidForm(tester);
        await tapVisible(tester, loginButton);
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('login_success'), findsOneWidget);
        expect(find.text(mainMarker), findsOneWidget);
        expect(find.byType(LoginMobileLayout), findsNothing);

        await flushSnackBar(tester);
      },
    );

    testWidgets(
      'failed login shows the error snackbar and stays on the screen',
      (tester) async {
        when(
          h.authRepo.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'wrong_credentials',
          ),
        );

        await h.pumpLogin(tester);

        await h.fillValidForm(tester);
        await tapVisible(tester, loginButton);
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('wrong_credentials'), findsOneWidget);
        expect(find.byType(LoginMobileLayout), findsOneWidget);
        expect(find.text(mainMarker), findsNothing);

        await flushSnackBar(tester);
      },
    );

    testWidgets('failed Google sign-in shows the generic error snackbar', (
      tester,
    ) async {
      when(h.authRepo.signInWithGoogle()).thenThrow(Exception('boom'));

      await h.pumpLogin(tester);

      await tapVisible(tester, socialButtons.at(0));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('generic_error_message'), findsOneWidget);
      expect(find.byType(LoginMobileLayout), findsOneWidget);

      await flushSnackBar(tester);
    });
  });
}