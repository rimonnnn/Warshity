import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/web_create_invoice_button.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('WebAddInvoice | Validation', () {
    testWidgets('shows an error when creating without a customer', (
      tester,
    ) async {
      await h.pumpWeb(tester);

      await tapVisible(tester, find.byType(WebCreateInvoiceButton));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('please_select_customer'), findsOneWidget);

      await flushSnackBar(tester);
    });

    testWidgets('shows an error when the customer is selected but cart is empty', (
      tester,
    ) async {
      h.invoiceCubit.selectCustomer(
        customerId: testCustomer.id!,
        customerName: testCustomer.name!,
      );

      await h.pumpWeb(tester);
      await tapVisible(tester, find.byType(WebCreateInvoiceButton));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('please_add_product'), findsOneWidget);

      await flushSnackBar(tester);
    });
  });

  group('WebAddInvoice | Form actions', () {
    testWidgets('updates invoice discount from the discount field', (
      tester,
    ) async {
      h.invoiceCubit.addProduct(testProduct);
      await h.pumpWeb(tester);

      await tester.enterText(fieldWithHint('enter_discount'), '2');
      await tester.pump();

      expect(h.invoiceCubit.state, isA<InvoiceLoaded>());
      expect(h.invoiceCubit.state.discount, 2);
      expect(h.invoiceCubit.state.total, 8);
    });
  });
}
