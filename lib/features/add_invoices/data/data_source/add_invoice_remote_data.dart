import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final invoiceSnapshot = await transaction.get(invoiceRef);

    if (invoiceSnapshot.exists) {
      final data = invoiceSnapshot.data();

      if (data?['stockDeducted'] == true) {
        return;
      }
    }

    final Map<String, int> quantities = {};

    for (final item in invoice.items) {
      quantities[item.productId] =
          (quantities[item.productId] ?? 0) + item.quantity;
    }

    final clientSnapshot = await transaction.get(clientRef);

    if (!clientSnapshot.exists) {
      throw Exception('Client not found');
    }

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

    final clientData = clientSnapshot.data() ?? {};

    final currentBalance =
        (clientData['balance'] as num?) ?? 0;

    final currentTotalPurchases =
        (clientData['totalPurchases'] as num?) ?? 0;

    final currentOrderCount =
        (clientData['orderCount'] as num?) ?? 0;

    final remainingAmount = invoice.remainingAmount;

    final newBalance =
        currentBalance + remainingAmount;

    transaction.set(
      invoiceRef,
      {
        ...invoice.toJson(),
        'stockDeducted': true,
      },
    );

    for (final entry in quantities.entries) {
      final productRef = firestore
          .collection('products')
          .doc(entry.key);

      transaction.update(productRef, {
        'quantity': FieldValue.increment(-entry.value),
      });
    }

    transaction.update(clientRef, {
      'totalPurchases':
          currentTotalPurchases + invoice.total,
      'orderCount':
          currentOrderCount + 1,
      if (remainingAmount > 0) ...{
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      },
    });
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
  Stream<List<InvoiceModel>> watchClientInvoices(
  String customerId,
) {
  return firestore
      .collection('invoices')
      .where(
        'customerId',
        isEqualTo: customerId,
      )
      .snapshots()
      .map((snapshot) {
        final invoices = snapshot.docs
            .map(
              (doc) => InvoiceModel.fromJson(
                doc.data(),
              ),
            )
            .toList();

        invoices.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt);
          final dateB = DateTime.tryParse(b.createdAt);

          if (dateA == null || dateB == null) {
            return 0;
          }

          return dateB.compareTo(dateA);
        });

        return invoices.take(5).toList();
      });
}

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await firestore.collection('invoices').doc(invoiceId).get();

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

      final availableQuantity = (data?['quantity'] as num?)?.toInt() ?? 0;

      if (entry.value > availableQuantity) {
        throw Exception(
          '${'Not enough stock. Available:'.tr()} $availableQuantity,'
          '${'Requested:'.tr()} ${entry.value}',
        );
      }
    }
  }
  Stream<List<InvoiceModel>> watchAllClientInvoices(
  String customerId,
) {
  return firestore
      .collection('invoices')
      .where(
        'customerId',
        isEqualTo: customerId,
      )
      .snapshots()
      .map((snapshot) {
    final invoices = snapshot.docs
        .map(
          (doc) => InvoiceModel.fromJson(
            doc.data(),
          ),
        )
        .toList();

    invoices.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt);
      final dateB = DateTime.tryParse(b.createdAt);

      if (dateA == null || dateB == null) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    return invoices;
  });
}

  Future<void> deleteInvoice(String invoiceId) async {
    await firestore.collection('invoices').doc(invoiceId).delete();
  }
}
