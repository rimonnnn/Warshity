import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

import '../helpers/register_test_helpers.dart';

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() {
    h = RegisterTestHarness();
  });

  group('RegisterMobileLayout | Validation', () {
    testWidgets('shows a required error for every field when the form is empty', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      await h.submit(tester);

      expect(find.text(errorOf(AppValidators.shopName, '')), findsOneWidget);
      expect(find.text(errorOf(AppValidators.accountName, '')), findsOneWidget);
      expect(find.text(errorOf(AppValidators.email, '')), findsOneWidget);
      expect(find.text(errorOf(AppValidators.password, '')), findsOneWidget);
      expect(
        find.text(AppValidators.confirmPassword('', '')!),
        findsOneWidget,
      );
      // The activity error uses the same key as the dropdown hint,
      // so the text appears twice (hint + error).
      expect(find.text('select_activity'), findsNWidgets(2));
      h.verifyRegisterNeverCalled();
    });

    testWidgets('shows a mismatch error when confirm password differs', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      await h.fillTextFields(tester, confirmPassword: 'Different@1');
      await h.selectActivity(tester);
      await h.acceptTerms(tester);
      await h.submit(tester);

      expect(
        find.text(
          AppValidators.confirmPassword('Different@1', validPassword)!,
        ),
        findsOneWidget,
      );
      h.verifyRegisterNeverCalled();
    });

    testWidgets('shows an error when the password is too short', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      // Confirm defaults to the same value, so only the length error shows.
      await h.fillTextFields(tester, password: '123');
      await h.selectActivity(tester);
      await h.acceptTerms(tester);
      await h.submit(tester);

      expect(
        find.text(errorOf(AppValidators.password, '123')),
        findsOneWidget,
      );
      h.verifyRegisterNeverCalled();
    });

    testWidgets('requires an activity to be selected', (tester) async {
      await h.pumpRegister(tester);

      await h.fillTextFields(tester);
      await h.acceptTerms(tester);
      await h.submit(tester);

      // Hint + error share the same text.
      expect(find.text('select_activity'), findsNWidgets(2));
      h.verifyRegisterNeverCalled();
    });

    testWidgets(
      'asks to accept the terms when the form is valid but unchecked',
      (tester) async {
        await h.pumpRegister(tester);

        await h.fillTextFields(tester);
        await h.selectActivity(tester);
        await h.submit(tester);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('validator_terms_required'), findsOneWidget);
        h.verifyRegisterNeverCalled();

        await flushSnackBar(tester);
      },
    );
  });
}