import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/invoice_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  group('InvoiceCard', () {
    testWidgets('paid invoice shows paid state, total and customer name', (
      tester,
    ) async {
      await pumpClientDetailsWidget(
        tester,
        InvoiceCard(invoice: makeInvoice(total: 100)),
      );

      expect(find.text('paid'), findsOneWidget);
      expect(find.text('unpaid'), findsNothing);
      expect(find.text('100.0'), findsOneWidget);
      expect(find.text('Ahmed Ali'), findsOneWidget);
    });

    testWidgets('unpaid invoice shows unpaid state', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        InvoiceCard(invoice: makeInvoice(total: 100, remaining: 40)),
      );

      expect(find.text('unpaid'), findsOneWidget);
      expect(find.text('paid'), findsNothing);
    });

    testWidgets('formats an ISO timestamp', (tester) async {
      await pumpClientDetailsWidget(tester, InvoiceCard(invoice: makeInvoice()));
      expect(find.text('05/01/2026 10:30 AM'), findsOneWidget);
    });

    testWidgets('shows the original date when it cannot be parsed', (
      tester,
    ) async {
      await pumpClientDetailsWidget(
        tester,
        InvoiceCard(invoice: makeInvoice(createdAt: 'غير معروف')),
      );
      expect(find.text('غير معروف'), findsOneWidget);
    });

    testWidgets('calls onTap when the card is tapped', (tester) async {
      var tapped = false;
      await pumpClientDetailsWidget(
        tester,
        InvoiceCard(invoice: makeInvoice(), onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InvoiceCard));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
