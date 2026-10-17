import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('MobileAddInvoice | Loading state', () {
    testWidgets('disables the create button while stock is being checked', (
      tester,
    ) async {
      h.invoiceCubit.selectCustomer(
        customerId: testCustomer.id!,
        customerName: testCustomer.name!,
      );
      h.invoiceCubit.addProduct(testProduct);
      h.invoicesRepository.stockCheckCompleter = Completer<void>();

      await h.pumpMobile(tester);
      await tapVisible(tester, find.byType(CreateInvoiceButton));
      await tester.pump();

      expect(h.invoiceCubit.state, isA<InvoiceLoading>());
      expect(find.byType(CreateInvoiceButton), findsOneWidget);

      final button = tester.widget<PrimaryButtonWidget>(primaryActionButton);
      expect(button.isLoading, isTrue);
      expect(button.onPress, isNull);
      expect(h.invoiceCubit.state.cartItems, hasLength(1));

      // Complete the pending operation so no asynchronous work is left over.
      h.invoicesRepository.stockCheckCompleter!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to the invoice review screen after success', (
      tester,
    ) async {
      h.invoiceCubit.selectCustomer(
        customerId: testCustomer.id!,
        customerName: testCustomer.name!,
      );
      h.invoiceCubit.addProduct(testProduct);

      await h.pumpMobile(tester);
      await tapVisible(tester, find.byType(CreateInvoiceButton));
      await tester.pumpAndSettle();

      expect(h.invoicesRepository.checkStockCalls, 1);
      expect(find.text(invoiceCheckMarker), findsOneWidget);
    });
  });
}
