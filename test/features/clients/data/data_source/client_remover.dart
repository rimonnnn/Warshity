import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'client_access_checker.dart';

/// حذف العميل وفواتيره مع إرجاع المخزون للفواتير المخصوم منها.
class ClientRemover {
  static const int _batchSize = 400;

  final FirebaseFirestore firestore;
  final Future<List<String>> Function() getActiveConnectionIds;

  ClientRemover(this.firestore, this.getActiveConnectionIds);

  Future<void> removeClient({
    required String uid,
    required String clientId,
  }) async {
    final clientRef = firestore.collection('clients').doc(clientId);
    final clientSnapshot = await clientRef.get();

    if (!clientSnapshot.exists) {
      throw Exception('client_not_found'.tr());
    }

    final clientData = clientSnapshot.data();

    if (clientData == null) {
      throw Exception('client_not_found'.tr());
    }

    final activeConnectionIds = await getActiveConnectionIds();

    final hasClientAccess = ClientAccessChecker.hasAccess(
      data: clientData,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
      requireActiveConnections: true,
    );

    if (!hasClientAccess) {
      throw Exception('client_not_found'.tr());
    }

    final snapshot = await firestore
        .collection('invoices')
        .where('customerId', isEqualTo: clientId)
        .get();

    final docs = snapshot.docs;

    for (var start = 0; start < docs.length; start += _batchSize) {
      final end = (start + _batchSize < docs.length)
          ? start + _batchSize
          : docs.length;

      await _deleteInvoicesBatch(
        docs.sublist(start, end),
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      );
    }

    await clientRef.delete();
  }

  Future<void> _deleteInvoicesBatch(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final batch = firestore.batch();
    final quantities = <String, int>{};

    for (final invoiceDoc in docs) {
      final data = invoiceDoc.data();

      final hasAccess = ClientAccessChecker.hasAccess(
        data: data,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      );

      if (!hasAccess) continue;

      if (data['stockDeducted'] == true) {
        _collectQuantities(data['items'], quantities);
      }

      batch.delete(invoiceDoc.reference);
    }

    for (final entry in quantities.entries) {
      batch.update(firestore.collection('products').doc(entry.key), {
        'quantity': FieldValue.increment(entry.value),
      });
    }

    await batch.commit();
  }

  void _collectQuantities(dynamic items, Map<String, int> quantities) {
    if (items is! List) return;

    for (final item in items) {
      if (item is! Map) continue;

      final productId = item['productId']?.toString() ?? '';
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

      if (productId.isEmpty || quantity <= 0) continue;

      quantities[productId] = (quantities[productId] ?? 0) + quantity;
    }
  }
}
