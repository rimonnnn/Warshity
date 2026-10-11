part of 'account_sharing_remote_data_source.dart';

/// Deleting a shared account and splitting the data back into per-user copies.
mixin _AccountSharingDelete on _AccountSharingCore, _AccountSharingConnections, _AccountSharingSeparation {
  Future<void> deleteSharedAccount(String connectionId) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    if (connectionId.trim().isEmpty) {
      throw Exception('shared_account_not_found'.tr());
    }

    final sharedAccountRef = firestore
        .collection('shared_accounts')
        .doc(connectionId);

    final sharedAccountSnapshot = await sharedAccountRef.get();

    if (!sharedAccountSnapshot.exists || sharedAccountSnapshot.data() == null) {
      throw Exception('shared_account_not_found'.tr());
    }

    final members = _normalizeIds(sharedAccountSnapshot.data()?['members']);

    if (members.length != 2 || !members.contains(currentUser.uid)) {
      throw Exception('shared_account_not_found'.tr());
    }

    final otherUserId = members.firstWhere((id) => id != currentUser.uid);

    final currentUserConnectionIds = await _getActiveConnectionIdsForUser(
      currentUser.uid,
    );

    final otherUserConnectionIds = await _getActiveConnectionIdsForUser(
      otherUserId,
    );

    final currentUserRemainingIds = currentUserConnectionIds
        .where((id) => id != connectionId)
        .toSet();

    final otherUserRemainingIds = otherUserConnectionIds
        .where((id) => id != connectionId)
        .toSet();

    final snapshotsByCollection =
        <String, QuerySnapshot<Map<String, dynamic>>>{};
    for (final collectionName in _dataCollections) {
      snapshotsByCollection[collectionName] = await firestore
          .collection(collectionName)
          .where(_sharedConnectionIdsField, arrayContains: connectionId)
          .get();
    }

    final clientLogicalIdsByDocumentId = <String, String>{};
    for (final doc in snapshotsByCollection['clients']!.docs) {
      clientLogicalIdsByDocumentId[doc.id] = _getLogicalDataId(
        doc.data(),
        doc.id,
      );
    }

    final productLogicalIdsByDocumentId = <String, String>{};
    for (final doc in snapshotsByCollection['products']!.docs) {
      productLogicalIdsByDocumentId[doc.id] = _getLogicalDataId(
        doc.data(),
        doc.id,
      );
    }

    for (final collectionName in _dataCollections) {
      final snapshot = snapshotsByCollection[collectionName]!;

      if (snapshot.docs.isEmpty) {
        continue;
      }

      final grouped = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

      for (final doc in snapshot.docs) {
        final logicalId = _getLogicalDataId(doc.data(), doc.id);

        final existing = grouped[logicalId];

        if (existing == null) {
          grouped[logicalId] = doc;
          continue;
        }

        grouped[logicalId] = _selectCanonicalDocument(
          firstDoc: existing,
          secondDoc: doc,
        );
      }

      const batchSize = 200;

      final entries = grouped.entries.toList();

      for (var start = 0; start < entries.length; start += batchSize) {
        final end = (start + batchSize < entries.length)
            ? start + batchSize
            : entries.length;

        final batch = firestore.batch();

        for (var index = start; index < end; index++) {
          final logicalDataId = entries[index].key;

          final sourceDoc = entries[index].value;

          final sourceData = Map<String, dynamic>.from(sourceDoc.data());

          final originalOwnerUid = sourceData['userId']?.toString();

          final sourceConnectionIds = _normalizeIds(
            sourceData[_sharedConnectionIdsField],
          );

          final currentCopyId = _getSeparatedDocumentId(
            collectionName: collectionName,
            logicalDataId: logicalDataId,
            uid: currentUser.uid,
          );

          final currentCopyRef = firestore
              .collection(collectionName)
              .doc(currentCopyId);

          final currentCopyData = Map<String, dynamic>.from(sourceData);

          currentCopyData['userId'] = currentUser.uid;

          currentCopyData['userIds'] = [currentUser.uid];

          final currentRemaining = sourceConnectionIds
              .where(currentUserRemainingIds.contains)
              .toList();

          currentCopyData[_sharedConnectionIdsField] = currentRemaining;

          final currentInherited = _normalizeIds(
            sourceData[_inheritedFromConnectionsField],
          );

          if (originalOwnerUid != null && originalOwnerUid != currentUser.uid) {
            currentInherited
              ..clear()
              ..addAll(currentRemaining);
          }

          if (currentInherited.isEmpty) {
            currentCopyData.remove(_inheritedFromConnectionsField);
          } else {
            currentCopyData[_inheritedFromConnectionsField] = currentInherited;
          }

          currentCopyData['sharedDataId'] = logicalDataId;
          if (collectionName == 'invoices') {
            currentCopyData['invoiceId'] = currentCopyId;
            _remapInvoiceReferenceIdsForSeparatedCopy(
              invoiceData: currentCopyData,
              uid: currentUser.uid,
              clientLogicalIdsByDocumentId: clientLogicalIdsByDocumentId,
              productLogicalIdsByDocumentId: productLogicalIdsByDocumentId,
            );
          }

          batch.set(currentCopyRef, currentCopyData);

          final otherCopyId = _getSeparatedDocumentId(
            collectionName: collectionName,
            logicalDataId: logicalDataId,
            uid: otherUserId,
          );

          final otherCopyRef = firestore
              .collection(collectionName)
              .doc(otherCopyId);

          final otherCopyData = Map<String, dynamic>.from(sourceData);

          otherCopyData['userId'] = otherUserId;

          otherCopyData['userIds'] = [otherUserId];

          final otherRemaining = sourceConnectionIds
              .where(otherUserRemainingIds.contains)
              .toList();

          otherCopyData[_sharedConnectionIdsField] = otherRemaining;

          final otherInherited = _normalizeIds(
            sourceData[_inheritedFromConnectionsField],
          );

          if (originalOwnerUid != null && originalOwnerUid != otherUserId) {
            otherInherited
              ..clear()
              ..addAll(otherRemaining);
          }

          if (otherInherited.isEmpty) {
            otherCopyData.remove(_inheritedFromConnectionsField);
          } else {
            otherCopyData[_inheritedFromConnectionsField] = otherInherited;
          }

          otherCopyData['sharedDataId'] = logicalDataId;
          if (collectionName == 'invoices') {
            otherCopyData['invoiceId'] = otherCopyId;
            _remapInvoiceReferenceIdsForSeparatedCopy(
              invoiceData: otherCopyData,
              uid: otherUserId,
              clientLogicalIdsByDocumentId: clientLogicalIdsByDocumentId,
              productLogicalIdsByDocumentId: productLogicalIdsByDocumentId,
            );
          }

          batch.set(otherCopyRef, otherCopyData);

          final targetCopyIds = <String>{currentCopyId, otherCopyId};

          for (final oldDoc in snapshot.docs.where(
            (doc) => _getLogicalDataId(doc.data(), doc.id) == logicalDataId,
          )) {
            if (targetCopyIds.contains(oldDoc.id)) {
              continue;
            }
            batch.delete(oldDoc.reference);
          }
        }

        await batch.commit();
      }
    }

    await Future.wait([
      _removeConnectionFromUserMapping(
        uid: currentUser.uid,
        connectionId: connectionId,
      ),
      _removeConnectionFromUserMapping(
        uid: otherUserId,
        connectionId: connectionId,
      ),
    ]);

    await sharedAccountRef.delete();
  }
}
