import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';


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

  /// كارت جاهزة + عميل متختار -> الحالة اللي قبل createInvoice
  void arrangeValidInvoice() {
    cubit.addProduct(buildProduct(price: 100.0));
    cubit.selectCustomer(customerId: 'customer-1', customerName: 'Customer 1');
    when(repository.checkStock(any)).thenAnswer((_) async {});
  }

  group('InvoiceCubit | createInvoice', () {
    test('should emit InvoiceError when no customer is selected', () async {
      cubit.addProduct(buildProduct(price: 100.0));

      await cubit.createInvoice();

      expect(cubit.state, isA<InvoiceError>());
    });

    test('should emit InvoiceError when cart is empty', () async {
      cubit.selectCustomer(customerId: 'customer_1', customerName: 'John');

      await cubit.createInvoice();

      expect(cubit.state, isA<InvoiceError>());
    });

    test('should emit InvoiceSuccess when invoice is created', () async {
      arrangeValidInvoice();

      await cubit.createInvoice();

      expect(cubit.state, isA<InvoiceSuccess>());

      final state = cubit.state as InvoiceSuccess;
      expect(state.invoice.customerId, 'customer-1');
      expect(state.invoice.customerName, 'Customer 1');
      expect(state.invoice.items.length, 1);
      expect(state.invoice.subtotal, 100.0);
      expect(state.invoice.total, 100.0);
    });
  });

  group('InvoiceCubit | saveInvoice', () {
    test('should save invoice', () async {
      final invoice = buildInvoice();
      when(repository.createInvoice(invoice)).thenAnswer((_) async {});

      await cubit.saveInvoice(invoice);

      verify(repository.createInvoice(invoice)).called(1);
    });

    test('should throw when saving invoice fails', () async {
      final invoice = buildInvoice();
      when(
        repository.createInvoice(invoice),
      ).thenThrow(Exception('Save failed'));

      expect(() => cubit.saveInvoice(invoice), throwsA(isA<Exception>()));
    });
  });

  group('InvoiceCubit | getInvoicePdfData', () {
    test('should return invoice PDF data', () async {
      arrangeValidInvoice();
      await cubit.createInvoice();

      final pdfData = cubit.getInvoicePdfData();

      expect(pdfData.invoiceId, isNotEmpty);
      expect(pdfData.createdAt, isNotEmpty);
      expect(pdfData.customerName, 'Customer 1');

      expect(pdfData.items.length, 1);
      expect(pdfData.items.first.productName, 'Product 1');
      expect(pdfData.items.first.quantity, 1);
      expect(pdfData.items.first.price, 100.0);

      expect(pdfData.subtotal, 100.0);
      expect(pdfData.discount, 0.0);
      expect(pdfData.total, 100.0);
      expect(pdfData.paidAmount, 0.0);
      expect(pdfData.remainingAmount, 100.0);
      expect(pdfData.discountAmount, 0.0);
    });

    test('should throw when invoice PDF data is not available', () {
      expect(() => cubit.getInvoicePdfData(), throwsA(isA<Exception>()));
    });
  });
}