import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_customer_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('MobileAddInvoice | Rendering', () {
    testWidgets('shows the main invoice sections', (tester) async {
      await h.pumpMobile(tester);

      expect(find.byType(InvoiceCustomerCard), findsOneWidget);
      expect(find.byType(InvoiceSearchBar), findsOneWidget);
      expect(find.byType(CartSection), findsOneWidget);
      expect(find.byType(InvoiceSummaryCard), findsOneWidget);
      expect(find.byType(CreateInvoiceButton), findsOneWidget);
      expect(find.text('add_invoice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('starts with an empty cart and zero totals', (tester) async {
      await h.pumpMobile(tester);

      expect(h.invoiceCubit.state.cartItems, isEmpty);
      expect(h.invoiceCubit.state.subtotal, 0);
      expect(h.invoiceCubit.state.total, 0);
    });
  });
}
