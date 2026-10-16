import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/features/auth/login/presentation/layout/login_mobile_layout.dart';

import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Rendering', () {
    testWidgets('shows all screen elements', (tester) async {
      await h.pumpLogin(tester);

      expect(find.byType(LoginMobileLayout), findsOneWidget);
      expect(find.text('welcome'), findsOneWidget);
      expect(find.text('startlogin'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('forget'), findsOneWidget);
      expect(loginButton, findsOneWidget);
      expect(socialButtons, findsNWidgets(2));
      expect(find.byType(FooterWidget), findsOneWidget);
    });

    testWidgets('starts with empty email and password fields', (tester) async {
      await h.pumpLogin(tester);

      final emailEditable = tester.widget<EditableText>(
        find.descendant(of: emailField, matching: find.byType(EditableText)),
      );
      final passwordEditable = tester.widget<EditableText>(
        find.descendant(of: passwordField, matching: find.byType(EditableText)),
      );

      expect(emailEditable.controller.text, isEmpty);
      expect(passwordEditable.controller.text, isEmpty);
    });
  });

  group('LoginMobileLayout | Password visibility', () {
    bool isObscured(WidgetTester tester) => tester
        .widget<EditableText>(
          find.descendant(
            of: passwordField,
            matching: find.byType(EditableText),
          ),
        )
        .obscureText;

    testWidgets('hides the password initially', (tester) async {
      await h.pumpLogin(tester);

      expect(isObscured(tester), isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('toggles password visibility when the eye icon is tapped', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      await tapVisible(tester, find.byIcon(Icons.visibility_off));
      expect(isObscured(tester), isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tapVisible(tester, find.byIcon(Icons.visibility));
      expect(isObscured(tester), isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}