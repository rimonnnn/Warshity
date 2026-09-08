import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';

class ClientsRemoteDataSource {
  final FirebaseFirestore firestore;

  ClientsRemoteDataSource(this.firestore);

  Stream<List<CustomerModel>> watchClients() {
    return firestore
        .collection('clients')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<CustomerModel> watchClient(String clientId) {
    return firestore.collection('clients').doc(clientId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Client not found');
      }

      return CustomerModel.fromFirestore(doc.id, doc.data()!);
    });
  }

  Future<void> addClient(CustomerModel client) async {
    await firestore.collection("clients").add(client.toFirestore());
  }

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('Client not found');
      }

      final data = snapshot.data() ?? {};

      final currentBalance = (data['balance'] as num?) ?? 0;

      if (amount <= 0) {
        throw Exception('Invalid debt amount');
      }

      if (amount > currentBalance) {
        throw Exception('Debt payment exceeds current balance');
      }

      final newBalance = currentBalance - amount;

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  Future<void> removeClient(String clientId) async {
  final invoicesRef = firestore.collection('invoices');
  final clientRef = firestore.collection('clients').doc(clientId);

  while (true) {
    // نجيب 400 فاتورة في كل مرة
    final snapshot = await invoicesRef
        .where('customerId', isEqualTo: clientId)
        .limit(400)
        .get();

    // مفيش فواتير تاني
    if (snapshot.docs.isEmpty) {
      break;
    }

    // نجمع كميات المنتجات اللي لازم ترجع للمخزون
    final Map<String, int> quantities = {};

    for (final invoiceDoc in snapshot.docs) {
      final data = invoiceDoc.data();

      final stockDeducted =
          data['stockDeducted'] == true;

      // لو الفاتورة كانت finalized
      if (stockDeducted) {
        final items = data['items'];

        if (items is List) {
          for (final item in items) {
            if (item is! Map) continue;

            final productId =
                item['productId']?.toString() ?? '';

            final quantity =
                (item['quantity'] as num?)?.toInt() ?? 0;

            if (productId.isEmpty || quantity <= 0) {
              continue;
            }

            quantities[productId] =
                (quantities[productId] ?? 0) + quantity;
          }
        }
      }
    }

    // Batch واحد لكل دفعة
    final batch = firestore.batch();

    // حذف الفواتير
    for (final invoiceDoc in snapshot.docs) {
      batch.delete(invoiceDoc.reference);
    }

    // إرجاع المنتجات للمخزون
    for (final entry in quantities.entries) {
      final productRef = firestore
          .collection('products')
          .doc(entry.key);

      batch.update(
        productRef,
        {
          'quantity': FieldValue.increment(entry.value),
        },
      );
    }

    await batch.commit();
  }

  // بعد حذف كل الفواتير نحذف العميل
  await clientRef.delete();
}
  Future<void> increaseDebt({
  required String clientId,
  required num amount,
}) async {
  final clientRef = firestore.collection('clients').doc(clientId);

  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(clientRef);

    if (!snapshot.exists) {
      throw Exception('Client not found');
    }

    final data = snapshot.data() ?? {};
    final currentBalance = (data['balance'] as num?) ?? 0;

    if (amount <= 0) return;

    final newBalance = currentBalance + amount;

    transaction.update(clientRef, {
      'balance': newBalance,
      'hasDebt': newBalance > 0,
    });
  });
}
}
