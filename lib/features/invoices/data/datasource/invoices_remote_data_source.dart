import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoicesRemoteDataSources {
  final FirebaseFirestore firestore;

  InvoicesRemoteDataSources(this.firestore);

  Stream<List<InvoiceModel>> watchInvoices() {
    return firestore
        .collection('invoices')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => InvoiceModel.fromJson(doc.data()),
              )
              .toList(),
        );
  }

  Future<void> deleteInvoice(String invoiceId) async {
    await firestore
        .collection('invoices')
        .doc(invoiceId)
        .delete();
  }
}