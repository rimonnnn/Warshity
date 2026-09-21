import 'package:mockito/annotations.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

// كل الموكات بتتولد من هنا بس -> invoice_test_helpers.mocks.dart
@GenerateMocks([InvoicesRepository])
ProductModel buildProduct({
  String id = '1',
  String name = 'Product 1',
  double price = 10.0,
  int quantity = 1,
}) {
  return ProductModel(
    id: id,
    name: name,
    price: price,
    quantity: quantity,
    barcode: '',
    category: '',
    unit: '',
    imageUrl: '',
  );
}

InvoiceModel buildInvoice({
  String invoiceId = 'INV-1',
  String customerId = 'customer-1',
  String customerName = 'Customer 1',
  double subtotal = 100.0,
  double discount = 10.0,
  double total = 90.0,
  double paidAmount = 50.0,
  double remainingAmount = 40.0,
}) {
  return InvoiceModel(
    invoiceId: invoiceId,
    customerId: customerId,
    customerName: customerName,
    createdAt: '2026-09-21T15:00:00',
    items: const [],
    subtotal: subtotal,
    discount: discount,
    total: total,
    paidAmount: paidAmount,
    remainingAmount: remainingAmount,
  );
}