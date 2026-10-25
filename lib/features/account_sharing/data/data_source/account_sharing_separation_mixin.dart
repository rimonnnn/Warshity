part of 'account_sharing_remote_data_source.dart';

/// Helpers used when separating data after a connection is removed.
mixin _AccountSharingSeparation on _AccountSharingCore {
  void _remapInvoiceReferenceIdsForSeparatedCopy({
    required Map<String, dynamic> invoiceData,
    required String uid,
    required Map<String, String> clientLogicalIdsByDocumentId,
    required Map<String, String> productLogicalIdsByDocumentId,
  }) {
    final customerId = invoiceData['customerId']?.toString();

    final customerLogicalId = customerId == null
        ? null
        : clientLogicalIdsByDocumentId[customerId];

    if (customerLogicalId != null) {
      invoiceData['customerId'] = _getSeparatedDocumentId(
        collectionName: 'clients',
        logicalDataId: customerLogicalId,
        uid: uid,
      );
    }

    for (final itemsKey in const ['items', 'productsItem']) {
      final rawItems = invoiceData[itemsKey];

      if (rawItems is! List) continue;

      final remappedItems = <dynamic>[];

      for (final rawItem in rawItems) {
        if (rawItem is! Map) {
          remappedItems.add(rawItem);
          continue;
        }

        final item = Map<String, dynamic>.from(rawItem);

        final productId = item['productId']?.toString();

        final productLogicalId = productId == null
            ? null
            : productLogicalIdsByDocumentId[productId];

        if (productLogicalId != null) {
          item['productId'] = _getSeparatedDocumentId(
            collectionName: 'products',
            logicalDataId: productLogicalId,
            uid: uid,
          );
        }

        remappedItems.add(item);
      }

      invoiceData[itemsKey] = remappedItems;
    }
  }

  Future<void> _removeConnectionFromUserMapping({
    required String uid,
    required String connectionId,
  }) async {
    // Prevent Firestore operations while account sharing is disabled.
    if (!FeatureFlags.accountSharingEnabled) {
      throw StateError('Account sharing is temporarily disabled.');
    }

    final ref = firestore.collection('user_shared_accounts').doc(uid);

    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.data() == null) {
      return;
    }

    final ids = _extractConnectionIds(snapshot.data()!);

    ids.remove(connectionId);

    await ref.set({
      _connectionIdsField: ids,
      _connectionsCountField: ids.length,
    }, SetOptions(merge: true));
  }
}
