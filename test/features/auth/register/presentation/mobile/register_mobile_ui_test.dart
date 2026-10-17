import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/features/auth/register/presentation/layout/register_mobile_layout.dart';
import 'package:warshity/features/auth/register/presentation/widgets/checkbox_widget.dart';

import '../helpers/register_test_helpers.dart';

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() {
    h = RegisterTestHarness();
  });

  bool isObscured(WidgetTester tester, Finder field) => tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .obscureText;

  group('RegisterMobileLayout | Rendering', () {
    testWidgets('shows all form fields, terms checkbox, buttons and footer', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      expect(find.byType(RegisterMobileLayout), findsOneWidget);
      expect(find.text('create_account'), findsOneWidget);
      expect(find.text('start'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(activityDropdown, findsOneWidget);
      expect(termsCheckbox, findsOneWidget);
      expect(createAccountButton, findsOneWidget);
      expect(socialButtons, findsNWidgets(2));
      expect(find.byType(FooterWidget), findsOneWidget);
    });

    testWidgets(
      'starts with empty fields, no activity selected and terms unchecked',
      (tester) async {
        await h.pumpRegister(tester);

        for (var i = 0; i < 5; i++) {
          final editable = tester.widget<EditableText>(
            find.descendant(
              of: find.byType(TextFormField).at(i),
              matching: find.byType(EditableText),
            ),
          );
          expect(editable.controller.text, isEmpty, reason: 'field #$i');
        }

        // The dropdown still shows its hint.
        expect(find.text('select_activity'), findsOneWidget);
        expect(
          tester.widget<CheckboxWidget>(find.byType(CheckboxWidget)).value,
          isFalse,
        );
      },
    );
  });

  group('RegisterMobileLayout | Password visibility', () {
    testWidgets('obscures both password fields initially', (tester) async {
      await h.pumpRegister(tester);

      expect(isObscured(tester, passwordField), isTrue);
      expect(isObscured(tester, confirmPasswordField), isTrue);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('each eye icon toggles only its own field', (tester) async {
      await h.pumpRegister(tester);

      // First icon belongs to the password field.
      await tapVisible(tester, find.byIcon(Icons.visibility_off).first);
      expect(isObscured(tester, passwordField), isFalse);
      expect(isObscured(tester, confirmPasswordField), isTrue);

      // The only remaining "visibility_off" icon belongs to the confirm field.
      await tapVisible(tester, find.byIcon(Icons.visibility_off));
      expect(isObscured(tester, passwordField), isFalse);
      expect(isObscured(tester, confirmPasswordField), isFalse);
    });
  });
}