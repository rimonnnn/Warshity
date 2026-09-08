import 'package:warshity/features/add_invoices/data/data_source/add_invoice_remote_data.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoicesRepository {
  final InvoicesRemoteDataSource remoteDataSource;

  InvoicesRepository(this.remoteDataSource);

  Future<void> createInvoice(InvoiceModel invoice) async {
    await remoteDataSource.createInvoice(invoice);
  }

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    await remoteDataSource.finalizeInvoice(invoice);
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    return remoteDataSource.watchInvoices();
  }


  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    return await remoteDataSource.getInvoice(invoiceId);
  }
  Future<void> checkStock(InvoiceModel invoice) async {
  await remoteDataSource.checkStock(invoice);
}
Future<void> deleteInvoice(String invoiceId) async {
  await remoteDataSource.deleteInvoice(invoiceId);
}
Stream<List<InvoiceModel>> watchClientInvoices(
  String customerId,
) {
  return remoteDataSource.watchClientInvoices(
    customerId,
  );
}
Stream<List<InvoiceModel>> watchAllClientInvoices(
  String customerId,
) {
  return remoteDataSource.watchAllClientInvoices(
    customerId,
  );
}
}