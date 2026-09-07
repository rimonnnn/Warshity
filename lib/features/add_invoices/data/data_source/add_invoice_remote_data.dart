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

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    final invoiceRef = firestore
        .collection('invoices')
        .doc(invoice.invoiceId);

    final clientRef = firestore
        .collection('clients')
        .doc(invoice.customerId);

    await firestore.runTransaction((transaction) async {
      // Check if invoice was already finalized
      final invoiceSnapshot = await transaction.get(invoiceRef);

      if (invoiceSnapshot.exists) {
        final data = invoiceSnapshot.data();

        if (data?['stockDeducted'] == true) {
          return;
        }
      }

      // Combine quantities if the same product appears more than once
      final Map<String, int> quantities = {};

      for (final item in invoice.items) {
        quantities[item.productId] =
            (quantities[item.productId] ?? 0) + item.quantity;
      }

      // Get client
      final clientSnapshot = await transaction.get(clientRef);

      if (!clientSnapshot.exists) {
        throw Exception('Client not found');
      }

      // Get all products
      final Map<String, DocumentSnapshot<Map<String, dynamic>>> products = {};

      for (final productId in quantities.keys) {
        final productRef = firestore
            .collection('products')
            .doc(productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('Product not found: $productId');
        }

        products[productId] = productSnapshot;
      }

      // Check stock
      for (final entry in quantities.entries) {
        final productId = entry.key;
        final requestedQuantity = entry.value;

        final productData = products[productId]!.data();

        final availableQuantity =
            (productData?['quantity'] as num?)?.toInt() ?? 0;

        if (requestedQuantity > availableQuantity) {
          throw Exception(
            'Not enough stock. Available: $availableQuantity, '
            'Requested: $requestedQuantity',
          );
        }
      }

      // Get current client balance
      final clientData = clientSnapshot.data() ?? {};

      final currentBalance =
          (clientData['balance'] as num?) ?? 0;

      final remainingAmount = invoice.remainingAmount;

      final newBalance =
          currentBalance + remainingAmount;

      // Save invoice
      transaction.set(
        invoiceRef,
        {
          ...invoice.toJson(),
          'stockDeducted': true,
        },
      );

      // Deduct stock
      for (final entry in quantities.entries) {
        final productRef = firestore
            .collection('products')
            .doc(entry.key);

        transaction.update(productRef, {
          'quantity': FieldValue.increment(-entry.value),
        });
      }

      // Update client balance
      if (remainingAmount > 0) {
        transaction.update(clientRef, {
          'balance': newBalance,
          'hasDebt': newBalance > 0,
        });
      }
    });
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

  Future<void> checkStock(InvoiceModel invoice) async {
    final Map<String, int> quantities = {};

    for (final item in invoice.items) {
      quantities[item.productId] =
          (quantities[item.productId] ?? 0) + item.quantity;
    }

    for (final entry in quantities.entries) {
      final productSnapshot = await firestore
          .collection('products')
          .doc(entry.key)
          .get();

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      final data = productSnapshot.data();

      final availableQuantity =
          (data?['quantity'] as num?)?.toInt() ?? 0;

      if (entry.value > availableQuantity) {
        throw Exception(
          'Not enough stock. Available: $availableQuantity, '
          'Requested: ${entry.value}',
        );
      }
    }
  }
  Future<void> deleteInvoice(String invoiceId) async {
  await firestore
      .collection('invoices')
      .doc(invoiceId)
      .delete();
}
}