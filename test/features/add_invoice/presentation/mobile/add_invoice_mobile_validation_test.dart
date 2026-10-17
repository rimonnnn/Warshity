import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('MobileAddInvoice | Validation', () {
    testWidgets('shows an error when creating without a customer', (
      tester,
    ) async {
      await h.pumpMobile(tester);

      await tapVisible(tester, find.byType(CreateInvoiceButton));
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

      await h.pumpMobile(tester);
      await tapVisible(tester, find.byType(CreateInvoiceButton));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('please_add_product'), findsOneWidget);

      await flushSnackBar(tester);
    });
  });
}
