import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_web_layout.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';

import '../helpers/login_test_helpers.dart';

/// The web layout has its own submit handler, BlocConsumer and disabled
/// states, so one smoke test per flow protects it from drifting away from
/// the mobile layout. Details are covered by the mobile tests.
void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginWebLayout | Login flow', () {
    testWidgets(
      'submits trimmed credentials and navigates to the main screen on success',
      (tester) async {
        await h.pumpWebLogin(tester);

        await tester.enterText(emailField, '  $validEmail  ');
        await tester.enterText(passwordField, '  $validPassword  ');
        await tapVisible(tester, loginButton);

        verify(
          h.authRepo.login(email: validEmail, password: validPassword),
        ).called(1);

        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('login_success'), findsOneWidget);
        expect(find.text(mainMarker), findsOneWidget);
        expect(find.byType(LoginWebLayout), findsNothing);

        await flushSnackBar(tester);
      },
    );

    testWidgets(
      'shows the error snackbar and stays on the screen when login fails',
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

        await h.pumpWebLogin(tester);

        await h.fillValidForm(tester);
        await tapVisible(tester, loginButton);
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('wrong_credentials'), findsOneWidget);
        expect(find.byType(LoginWebLayout), findsOneWidget);
        expect(find.text(mainMarker), findsNothing);

        await flushSnackBar(tester);
      },
    );
  });

  group('LoginWebLayout | Loading state', () {
    testWidgets(
      'disables remember me, forgot password, social buttons and footer',
      (tester) async {
        await h.pumpWebLogin(tester);

        final completer = await h.startLoading(tester);

        final button = tester.widget<PrimaryButtonWidget>(loginButton);
        expect(button.isLoading, isTrue);
        expect(button.onPress, isNull);

        expect(
          tester.widget<CheckboxWidget>(find.byType(CheckboxWidget)).onChanged,
          isNull,
        );
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, 'forget'))
              .onPressed,
          isNull,
        );
        for (var i = 0; i < 2; i++) {
          expect(
            tester.widget<OutlinedButtonWidget>(socialButtons.at(i)).onPressed,
            isNull,
          );
        }
        expect(
          tester.widget<FooterWidget>(find.byType(FooterWidget)).onPress,
          isNull,
        );

        completer.complete(MockUserCredential());
        await flushSnackBar(tester);
      },
    );
  });
}