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
              .map((doc) => InvoiceModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final invoiceRef = firestore.collection('invoices').doc(invoiceId);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      if (!invoiceSnapshot.exists) {
        throw Exception('Invoice not found');
      }

      final invoiceData = invoiceSnapshot.data();

      if (invoiceData == null) {
        throw Exception('Invoice data not found');
      }

      final stockDeducted = invoiceData['stockDeducted'] == true;

      final customerId = invoiceData['customerId']?.toString() ?? '';

      final total = (invoiceData['total'] as num?)?.toDouble() ?? 0.0;

      final remainingAmount =
          (invoiceData['remainingAmount'] as num?)?.toDouble() ?? 0.0;

      DocumentSnapshot<Map<String, dynamic>>? clientSnapshot;

      if (customerId.isNotEmpty) {
        final clientRef = firestore.collection('clients').doc(customerId);

        clientSnapshot = await transaction.get(clientRef);

        if (!clientSnapshot.exists) {
          throw Exception('Client not found');
        }
      }

      if (clientSnapshot != null) {
        final clientData = clientSnapshot.data() ?? {};

        final currentTotalPurchases =
            (clientData['totalPurchases'] as num?) ?? 0;

        final currentOrderCount = (clientData['orderCount'] as num?) ?? 0;

        final currentBalance = (clientData['balance'] as num?) ?? 0;

        final newTotalPurchases = (currentTotalPurchases - total).clamp(
          0,
          double.infinity,
        );

        final newOrderCount = (currentOrderCount - 1).clamp(0, double.infinity);

        final newBalance = (currentBalance - remainingAmount).clamp(
          0,
          double.infinity,
        );

        transaction.update(firestore.collection('clients').doc(customerId), {
          'totalPurchases': newTotalPurchases,
          'orderCount': newOrderCount,
          'balance': newBalance,
          'hasDebt': newBalance > 0,
        });
      }

      if (stockDeducted) {
        final items = invoiceData['items'];

        if (items is List) {
          final Map<String, int> quantities = {};

          for (final item in items) {
            if (item is! Map) continue;

            final productId = item['productId']?.toString() ?? '';

            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

            if (productId.isEmpty || quantity <= 0) {
              continue;
            }

            quantities[productId] = (quantities[productId] ?? 0) + quantity;
          }

          for (final entry in quantities.entries) {
            final productRef = firestore.collection('products').doc(entry.key);

            transaction.update(productRef, {
              'quantity': FieldValue.increment(entry.value),
            });
          }
        }
      }

      transaction.delete(invoiceRef);
    });
  }
}
