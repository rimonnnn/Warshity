import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/footer_widget.dart';

import '../helpers/login_test_helpers.dart';

void main() {
  setUpAll(setUpLoginTestEnvironment);

  late LoginTestHarness h;
  setUp(() {
    h = LoginTestHarness();
  });

  group('LoginMobileLayout | Navigation', () {
    testWidgets('forgot password opens the forgot password screen', (
      tester,
    ) async {
      await h.pumpLogin(tester);

      await tapVisible(tester, find.widgetWithText(TextButton, 'forget'));
      await tester.pumpAndSettle();

      expect(find.text(forgetMarker), findsOneWidget);
    });

    testWidgets('footer opens the register screen', (tester) async {
      await h.pumpLogin(tester);

      // Call the callback directly so the test does not depend on how
      // FooterWidget renders its tappable text.
      tester.widget<FooterWidget>(find.byType(FooterWidget)).onPress!();
      await tester.pumpAndSettle();

      expect(find.text(registerMarker), findsOneWidget);
    });
  });
}