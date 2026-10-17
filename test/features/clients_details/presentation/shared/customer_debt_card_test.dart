import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_debt_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  group('CustomerDebtCard', () {
    testWidgets('shows the debt title and amount', (tester) async {
      await pumpClientDetailsWidget(tester, const CustomerDebtCard(amount: '250'));

      expect(find.text('current_debt'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('calls onPayDebt when payment is tapped', (tester) async {
      var tapped = false;
      await pumpClientDetailsWidget(
        tester,
        CustomerDebtCard(amount: '250', onPayDebt: () => tapped = true),
      );

      await tapVisible(tester, find.text('pay_debt'));
      expect(tapped, isTrue);
    });
  });
}
