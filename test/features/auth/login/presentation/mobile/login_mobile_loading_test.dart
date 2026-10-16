import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/core/widgets/outlined_button_widget.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

import '../../../cubit/auth_mocks.mocks.dart';
import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Loading state', () {
    testWidgets('keeps the screen visible and disables all buttons', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      final completer = await h.startLoading(tester);

      // The screen itself is still visible.
      expect(find.byType(TextFormField), findsNWidgets(2));

      // The login button is loading and has no onPress.
      final button = tester.widget<PrimaryButtonWidget>(loginButton);
      expect(button.isLoading, isTrue);
      expect(button.onPress, isNull);

      // Forgot password is disabled.
      final forget = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'forget'),
      );
      expect(forget.onPressed, isNull);

      // Social buttons are disabled.
      for (var i = 0; i < 2; i++) {
        final social = tester.widget<OutlinedButtonWidget>(
          socialButtons.at(i),
        );
        expect(social.onPressed, isNull);
      }

      // Footer is disabled.
      expect(
        tester.widget<FooterWidget>(find.byType(FooterWidget)).onPress,
        isNull,
      );

      completer.complete(MockUserCredential());
      await flushSnackBar(tester);
    });

    testWidgets('tapping login while loading does not call the repo again', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      final completer = await h.startLoading(tester);
      await tapVisible(tester, loginButton);

      verify(
        h.authRepo.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).called(1);

      completer.complete(MockUserCredential());
      await flushSnackBar(tester);
    });

    testWidgets('re-enables the login button when login fails', (tester) async {
      await h.pumpLogin(tester);

      final completer = await h.startLoading(tester);
      expect(tester.widget<PrimaryButtonWidget>(loginButton).isLoading, isTrue);

      completer.completeError(
        FirebaseAuthException(code: 'wrong-password', message: 'wrong'),
      );
      await tester.pump();

      final button = tester.widget<PrimaryButtonWidget>(loginButton);
      expect(button.isLoading, isFalse);
      expect(button.onPress, isNotNull);

      await flushSnackBar(tester);
    });
  });
}