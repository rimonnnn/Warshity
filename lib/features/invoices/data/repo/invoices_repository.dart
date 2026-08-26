import 'package:warshity/features/invoices/data/datasource/invoices_remote_data_source.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoiceRepository {
  final InvoicesRemoteDataSources remoteDataSource;

  InvoiceRepository(this.remoteDataSource);

  Stream<List<InvoiceModel>> watchInvoices() {
    return remoteDataSource.watchInvoices();
  }

  Future<void> deleteInvoice(String invoiceId) {
    return remoteDataSource.deleteInvoice(invoiceId);
  }
}