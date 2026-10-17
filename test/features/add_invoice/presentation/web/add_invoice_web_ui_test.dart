import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_customer_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_discount_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_invoice_preview.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('WebAddInvoice | Rendering', () {
    testWidgets('shows the editor, summary, create action, and preview', (
      tester,
    ) async {
      await h.pumpWeb(tester);

      expect(find.byType(WebCustomerSection), findsOneWidget);
      expect(find.byType(WebCartSection), findsOneWidget);
      expect(find.byType(WebDiscountSection), findsOneWidget);
      expect(find.byType(InvoiceSummaryCard), findsOneWidget);
      expect(find.byType(WebCreateInvoiceButton), findsOneWidget);
      expect(find.byType(WebInvoicePreview), findsOneWidget);
      expect(find.text('add_invoice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
