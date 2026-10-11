part of 'account_sharing_remote_data_source.dart';

/// Merging user data once an invitation is accepted.
mixin _AccountSharingMerge on _AccountSharingCore {
  Future<void> _mergeDataForConnection({
    required String firstUid,
    required String secondUid,
    required String connectionId,
    required bool firstHadOtherConnections,
    required bool secondHadOtherConnections,
  }) async {
    for (final collectionName in _dataCollections) {
      final firstSnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: firstUid)
          .get();

      final secondSnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: secondUid)
          .get();

      final firstEligible =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

      final secondEligible =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

      for (final doc in firstSnapshot.docs) {
        final data = doc.data();

        if (!_canShareRecordToConnection(
          data: data,
          connectionId: connectionId,
          hadOtherConnectionsBeforeLink: firstHadOtherConnections,
        )) {
          continue;
        }

        final logicalId = _getLogicalDataId(data, doc.id);

        firstEligible[logicalId] = doc;
      }

      for (final doc in secondSnapshot.docs) {
        final data = doc.data();

        if (!_canShareRecordToConnection(
          data: data,
          connectionId: connectionId,
          hadOtherConnectionsBeforeLink: secondHadOtherConnections,
        )) {
          continue;
        }

        final logicalId = _getLogicalDataId(data, doc.id);

        secondEligible[logicalId] = doc;
      }

      final logicalIds = <String>{
        ...firstEligible.keys,
        ...secondEligible.keys,
      };

      if (logicalIds.isEmpty) {
        continue;
      }

      const batchSize = 200;

      final logicalIdList = logicalIds.toList();

      for (var start = 0; start < logicalIdList.length; start += batchSize) {
        final end = (start + batchSize < logicalIdList.length)
            ? start + batchSize
            : logicalIdList.length;

        final batch = firestore.batch();

        for (var index = start; index < end; index++) {
          final logicalId = logicalIdList[index];

          final firstDoc = firstEligible[logicalId];

          final secondDoc = secondEligible[logicalId];

          if (firstDoc != null && secondDoc == null) {
            final data = Map<String, dynamic>.from(firstDoc.data());

            _prepareMergedData(
              data: data,
              connectionId: connectionId,
              otherUid: secondUid,
            );

            batch.update(firstDoc.reference, data);

            continue;
          }

          if (firstDoc == null && secondDoc != null) {
            final data = Map<String, dynamic>.from(secondDoc.data());

            _prepareMergedData(
              data: data,
              connectionId: connectionId,
              otherUid: firstUid,
            );

            batch.update(secondDoc.reference, data);

            continue;
          }

          final first = firstDoc!;
          final second = secondDoc!;

          final canonical = _selectCanonicalDocument(
            firstDoc: first,
            secondDoc: second,
          );

          final duplicate = canonical.id == first.id ? second : first;

          final canonicalData = Map<String, dynamic>.from(canonical.data());

          final firstConnections = _normalizeIds(
            first.data()[_sharedConnectionIdsField],
          );

          final secondConnections = _normalizeIds(
            second.data()[_sharedConnectionIdsField],
          );

          final mergedConnections = <String>{
            ...firstConnections,
            ...secondConnections,
            connectionId,
          };

          canonicalData[_sharedConnectionIdsField] = mergedConnections.toList();

          canonicalData['userIds'] = [firstUid, secondUid];

          canonicalData['sharedDataId'] = logicalId;

          final inherited = _normalizeIds(
            canonicalData[_inheritedFromConnectionsField],
          );

          inherited.remove(connectionId);

          if (inherited.isEmpty) {
            canonicalData.remove(_inheritedFromConnectionsField);
          } else {
            canonicalData[_inheritedFromConnectionsField] = inherited;
          }

          batch.set(canonical.reference, canonicalData);

          batch.delete(duplicate.reference);
        }

        await batch.commit();
      }
    }
  }

  void _prepareMergedData({
    required Map<String, dynamic> data,
    required String connectionId,
    required String otherUid,
  }) {
    final ids = _normalizeIds(data[_sharedConnectionIdsField]);

    ids.add(connectionId);

    data[_sharedConnectionIdsField] = ids;

    final ownerUid = data['userId']?.toString();

    final userIds = <String>{
      if (ownerUid != null && ownerUid.isNotEmpty) ownerUid,
      otherUid,
    };

    data['userIds'] = userIds.toList();

    final inherited = _normalizeIds(data[_inheritedFromConnectionsField]);

    inherited.remove(connectionId);

    if (inherited.isEmpty) {
      data.remove(_inheritedFromConnectionsField);
    } else {
      data[_inheritedFromConnectionsField] = inherited;
    }
  }

  Future<void> _addConnectionToUserData({
    required String ownerUid,
    required String connectionId,
    required bool hadOtherConnectionsBeforeLink,
  }) async {
    if (ownerUid.isEmpty || connectionId.isEmpty) {
      return;
    }

    for (final collectionName in _dataCollections) {
      final snapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: ownerUid)
          .get();

      if (snapshot.docs.isEmpty) {
        continue;
      }

      const batchSize = 400;

      for (var start = 0; start < snapshot.docs.length; start += batchSize) {
        final end = (start + batchSize < snapshot.docs.length)
            ? start + batchSize
            : snapshot.docs.length;

        final batch = firestore.batch();

        var operationCount = 0;

        for (var index = start; index < end; index++) {
          final doc = snapshot.docs[index];

          final data = doc.data();

          if (!_canShareRecordToConnection(
            data: data,
            connectionId: connectionId,
            hadOtherConnectionsBeforeLink: hadOtherConnectionsBeforeLink,
          )) {
            continue;
          }

          final ids = _normalizeIds(data[_sharedConnectionIdsField]);

          if (!ids.contains(connectionId)) {
            ids.add(connectionId);
          }

          final inherited = _normalizeIds(data[_inheritedFromConnectionsField]);

          inherited.remove(connectionId);

          final updateData = <String, dynamic>{_sharedConnectionIdsField: ids};

          if (inherited.isEmpty) {
            updateData[_inheritedFromConnectionsField] = FieldValue.delete();
          } else {
            updateData[_inheritedFromConnectionsField] = inherited;
          }

          batch.update(doc.reference, updateData);

          operationCount++;
        }

        if (operationCount > 0) {
          await batch.commit();
        }
      }
    }
  }
}
