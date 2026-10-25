import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/auth/cubit/auth_state.dart';
import 'package:warshity/features/auth/register/presentation/layout/register_mobile_layout.dart';

import '../helpers/register_test_helpers.dart';

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() {
    h = RegisterTestHarness();
  });

  group('RegisterMobileLayout | Result states', () {
    testWidgets(
      'shows the success snackbar when the verification email is sent',
      (tester) async {
        await h.pumpRegister(tester);

        // Trigger the operation.
        await h.cubit.resendVerificationEmail();

        // Verify repository interaction.
        verify(h.registerRepo.resendEmailVerification()).called(1);

        // Verify the emitted state.
        expect(h.cubit.state, isA<EmailVerificationSent>());

        // Process pending frames and animations.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('verification_email_sent'), findsOneWidget);

        await flushSnackBar(tester);
      },
    );
    testWidgets('shows the error snackbar when registration fails', (
      tester,
    ) async {
      when(
        h.registerRepo.register(
          user: anyNamed('user'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'email_already_in_use',
        ),
      );

      await h.pumpRegister(tester);

      await h.fillValidForm(tester);
      await h.submit(tester);
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('email_already_in_use'), findsOneWidget);
      expect(find.byType(RegisterMobileLayout), findsOneWidget);

      await flushSnackBar(tester);
    });
  });

  // Nothing on this screen triggers it, but the listener handles
  // EmailVerificationSent, so we drive the cubit directly.
}
