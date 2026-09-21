import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';

import 'invoice_test_helpers_test.dart';
import 'invoice_test_helpers_test.mocks.dart';


void main() {
  group('InvoiceCubit | Customer', () {
    late InvoiceCubit cubit;
    late MockInvoicesRepository repository;

    setUp(() {
      repository = MockInvoicesRepository();
      cubit = InvoiceCubit(repository);
    });

    tearDown(() async => cubit.close());

    test('should select customer', () {
      cubit.selectCustomer(customerId: 'customer_1', customerName: 'John');

      expect(cubit.state.selectedCustomerId, 'customer_1');
      expect(cubit.state.selectedCustomerName, 'John');
    });

    test('should remove selected customer', () {
      cubit.selectCustomer(customerId: '1', customerName: 'Rimon');

      cubit.removeCustomer();

      expect(cubit.state.selectedCustomerId, isNull);
      expect(cubit.state.selectedCustomerName, isNull);
    });

    test('should select customer without changing invoice data', () {
      cubit.addProduct(buildProduct(price: 100.0));
      cubit.updateDiscount(20);
      cubit.updatePaidAmount(30);

      cubit.selectCustomer(customerId: 'customer_1', customerName: 'John');

      expect(cubit.state.selectedCustomerId, 'customer_1');
      expect(cubit.state.selectedCustomerName, 'John');

      expect(cubit.state.cartItems.length, 1);
      expect(cubit.state.subtotal, 100.0);
      expect(cubit.state.discount, 20.0);
      expect(cubit.state.total, 80.0);
      expect(cubit.state.paidAmount, 30.0);
      expect(cubit.state.remainingAmount, 50.0);
    });
  });
}