import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoicesRemoteDataSource {
  final FirebaseFirestore firestore;

  InvoicesRemoteDataSource(this.firestore);

  Future<void> createInvoice(InvoiceModel invoice) async {
    await firestore
        .collection('invoices')
        .doc(invoice.invoiceId)
        .set(invoice.toJson());
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    return firestore
        .collection('invoices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InvoiceModel.fromJson(doc.data());
      }).toList();
    });
  }

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await firestore
        .collection('invoices')
        .doc(invoiceId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return InvoiceModel.fromJson(doc.data()!);
  }
}