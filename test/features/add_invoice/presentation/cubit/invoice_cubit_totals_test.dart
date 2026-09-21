import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';


import 'invoice_test_helpers_test.dart';
import 'invoice_test_helpers_test.mocks.dart';

void main() {
  late InvoiceCubit cubit;
  late MockInvoicesRepository repository;

  setUp(() {
    repository = MockInvoicesRepository();
    cubit = InvoiceCubit(repository);
  });

  tearDown(() async => cubit.close());

  group('InvoiceCubit | Discount', () {
    test('should update discount', () {
      cubit.addProduct(buildProduct());
      cubit.increaseQuantity('1');
      cubit.increaseQuantity('1');

      cubit.updateDiscount(10);

      expect(cubit.state.subtotal, 30.0);
      expect(cubit.state.discount, 10.0);
      expect(cubit.state.total, 20.0);
      expect(cubit.state.paidAmount, 0.0);
      expect(cubit.state.remainingAmount, 20.0);
    });

    test('should clamp discount to subtotal', () {
      cubit.addProduct(buildProduct());

      cubit.updateDiscount(50);

      expect(cubit.state.subtotal, 10.0);
      expect(cubit.state.discount, 10.0);
      expect(cubit.state.total, 0.0);
      expect(cubit.state.remainingAmount, 0.0);
    });

    test('should not allow negative discount', () {
      cubit.addProduct(buildProduct());

      cubit.updateDiscount(-5);

      expect(cubit.state.discount, 0.0);
      expect(cubit.state.total, 10.0);
      expect(cubit.state.remainingAmount, 10.0);
    });
  });

  group('InvoiceCubit | Paid amount', () {
    test('should update paid amount', () {
      cubit.addProduct(buildProduct(price: 100.0));

      cubit.updatePaidAmount(40);

      expect(cubit.state.subtotal, 100.0);
      expect(cubit.state.total, 100.0);
      expect(cubit.state.paidAmount, 40.0);
      expect(cubit.state.remainingAmount, 60.0);
    });

    test('should clamp paid amount to total', () {
      cubit.addProduct(buildProduct(price: 100.0));

      cubit.updatePaidAmount(150);

      expect(cubit.state.total, 100.0);
      expect(cubit.state.paidAmount, 100.0);
      expect(cubit.state.remainingAmount, 0.0);
    });

    test('should not allow negative paid amount', () {
      cubit.addProduct(buildProduct(price: 100.0));

      cubit.updatePaidAmount(-20);

      expect(cubit.state.paidAmount, 0.0);
      expect(cubit.state.remainingAmount, 100.0);
    });
  });
}