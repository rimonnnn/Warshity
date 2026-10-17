import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_balance_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  group('CustomerBalanceCard', () {
    testWidgets('shows the debt amount, currency and payment action', (
      tester,
    ) async {
      await pumpClientDetailsWidget(
        tester,
        CustomerBalanceCard(balance: 150, onPay: () {}),
      );

      expect(find.text('current_debt'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('EGP'), findsOneWidget);
      expect(find.text('pay_debt'), findsOneWidget);
    });

    testWidgets('calls onPay when the payment button is tapped', (tester) async {
      var paid = false;
      await pumpClientDetailsWidget(
        tester,
        CustomerBalanceCard(balance: 150, onPay: () => paid = true),
      );

      await tapVisible(tester, find.text('pay_debt'));
      expect(paid, isTrue);
    });
  });
}
