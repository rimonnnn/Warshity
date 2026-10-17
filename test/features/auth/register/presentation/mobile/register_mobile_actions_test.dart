import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/widgets/footer_widget.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

import '../helpers/register_test_helpers.dart';

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() {
    h = RegisterTestHarness();
  });

  group('RegisterMobileLayout | Register action', () {
    testWidgets('calls register once with the trimmed form data', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      // Confirm defaults to the padded password, so both match exactly.
      await h.fillTextFields(
        tester,
        shopName: '  $validShopName  ',
        ownerName: '  $validOwnerName  ',
        email: '  $validEmail  ',
        password: '  $validPassword  ',
      );
      await h.selectActivity(tester);
      await h.acceptTerms(tester);
      await h.submit(tester);

      final verification = verify(
        h.registerRepo.register(
          user: captureAnyNamed('user'),
          password: captureAnyNamed('password'),
        ),
      );
      expect(verification.callCount, 1);

      final user = verification.captured[0] as UserModel;
      final password = verification.captured[1] as String;

      expect(user.uid, isEmpty);
      expect(user.shopName, validShopName);
      expect(user.ownerName, validOwnerName);
      expect(user.email, validEmail);
      expect(user.activity, validActivity);
      expect(password, validPassword);

      await flushSnackBar(tester); // RegisterSuccess → snackbar
    });
  });

  group('RegisterMobileLayout | Social sign-in', () {
    testWidgets('Google button calls signInWithGoogle', (tester) async {
      await h.pumpRegister(tester);

      await tapVisible(tester, socialButtons.at(0));

      verify(h.authRepo.signInWithGoogle()).called(1);
      verifyNever(h.authRepo.signInWithFacebook());
    });

    testWidgets('Facebook button calls signInWithFacebook', (tester) async {
      await h.pumpRegister(tester);

      await tapVisible(tester, socialButtons.at(1));

      verify(h.authRepo.signInWithFacebook()).called(1);
      verifyNever(h.authRepo.signInWithGoogle());
    });
  });

  group('RegisterMobileLayout | Navigation', () {
    testWidgets('footer opens the login screen', (tester) async {
      await h.pumpRegister(tester);

      // Call the callback directly so the test does not depend on how
      // FooterWidget renders its tappable text.
      tester.widget<FooterWidget>(find.byType(FooterWidget)).onPress!();
      await tester.pumpAndSettle();

      expect(find.text(loginMarker), findsOneWidget);
    });
  });
}