import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';


import 'invoice_test_helpers_test.dart';
import 'invoice_test_helpers_test.mocks.dart';

void main() {
  group('InvoiceCubit | Cart', () {
    late InvoiceCubit cubit;
    late MockInvoicesRepository repository;

    setUp(() {
      repository = MockInvoicesRepository();
      cubit = InvoiceCubit(repository);
    });

    tearDown(() async => cubit.close());

    test('should add product to cart', () {
      cubit.addProduct(buildProduct());

      expect(cubit.state.cartItems.length, 1);
      expect(cubit.state.cartItems.first.productId, '1');
      expect(cubit.state.cartItems.first.productName, 'Product 1');
      expect(cubit.state.cartItems.first.price, 10.0);
      expect(cubit.state.cartItems.first.quantity, 1);

      expect(cubit.state.subtotal, 10.0);
      expect(cubit.state.total, 10.0);
      expect(cubit.state.discount, 0.0);
      expect(cubit.state.paidAmount, 0.0);
      expect(cubit.state.remainingAmount, 10.0);
    });

    test('should remove selected product', () {
      cubit.addProduct(buildProduct());

      cubit.removeProduct('1');

      expect(
        cubit.state.cartItems.any((item) => item.productId == '1'),
        isFalse,
      );
    });

    test('should increase product quantity', () {
      cubit.addProduct(buildProduct());

      cubit.increaseQuantity('1');

      expect(cubit.state.cartItems.first.quantity, 2);
      expect(cubit.state.subtotal, 20.0);
      expect(cubit.state.total, 20.0);
      expect(cubit.state.remainingAmount, 20.0);
    });

    test('should decrease product quantity', () {
      cubit.addProduct(buildProduct());
      cubit.increaseQuantity('1');

      cubit.decreaseQuantity('1');

      expect(cubit.state.cartItems.first.quantity, 1);
      expect(cubit.state.subtotal, 10.0);
      expect(cubit.state.total, 10.0);
      expect(cubit.state.remainingAmount, 10.0);
    });

    test('should remove product when quantity reaches zero', () {
      cubit.addProduct(buildProduct());

      cubit.decreaseQuantity('1');

      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.subtotal, 0.0);
      expect(cubit.state.total, 0.0);
      expect(cubit.state.remainingAmount, 0.0);
    });

    test('should clear cart and reset invoice totals', () {
      cubit.addProduct(buildProduct(price: 100.0));
      cubit.updateDiscount(20);
      cubit.updatePaidAmount(30);

      cubit.clearCart();

      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.discount, 0.0);
      expect(cubit.state.subtotal, 0.0);
      expect(cubit.state.total, 0.0);
      expect(cubit.state.paidAmount, 0.0);
      expect(cubit.state.remainingAmount, 0.0);
    });
  });
}