import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_item.dart';

import '../helpers/add_invoice_test_helpers.dart';

void main() {
  setUpAll(setUpAddInvoiceTestEnvironment);

  late AddInvoiceTestHarness h;

  setUp(() async {
    h = await AddInvoiceTestHarness.create();
  });

  group('MobileAddInvoice | Customer search', () {
    testWidgets('searches for and selects a customer', (tester) async {
      h.clientsRepository.clients.add(testCustomer);
      await h.pumpMobile(tester);

      await tester.enterText(fieldWithHint('search_clients'), 'Test');
      await tester.pumpAndSettle();

      expect(find.text('Test Customer'), findsOneWidget);

      await tapVisible(tester, find.text('Test Customer'));
      await tester.pumpAndSettle();

      expect(h.invoiceCubit.state.selectedCustomerId, 'customer-1');
      expect(h.invoiceCubit.state.selectedCustomerName, 'Test Customer');
    });
  });

  group('MobileAddInvoice | Product search', () {
    testWidgets('adds a searched product to the cart', (tester) async {
      h.productsRepository.products.add(testProduct);
      await h.pumpMobile(tester);

      await tester.enterText(fieldWithHint('search_products'), 'Wood');
      await tester.pumpAndSettle();

      // The query remains in the search field, so find.text('Wood') also
      // matches the EditableText. Target the product result ListTile directly.
      final productResult = find.widgetWithText(ListTile, 'Wood');
      expect(productResult, findsOneWidget);

      await tapVisible(tester, productResult);
      await tester.pumpAndSettle();

      expect(h.invoiceCubit.state.cartItems, hasLength(1));
      expect(h.invoiceCubit.state.cartItems.single.productName, 'Wood');
      expect(h.invoiceCubit.state.subtotal, 10);
      expect(
        find.descendant(
          of: find.byType(CartItem),
          matching: find.text('Wood'),
        ),
        findsOneWidget,
      );
    });
  });
}
