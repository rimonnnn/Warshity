part of 'account_sharing_remote_data_source.dart';

/// Reads/watches the active shared-account connections of the current user.
mixin _AccountSharingConnections on _AccountSharingCore {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getUserConnectionDocuments(String uid) async {
    final mappingRef = firestore.collection('user_shared_accounts').doc(uid);

    final mappingSnapshot = await mappingRef.get();

    if (!mappingSnapshot.exists || mappingSnapshot.data() == null) {
      return [];
    }

    final connectionIds = _extractConnectionIds(mappingSnapshot.data()!);

    if (connectionIds.isEmpty) {
      return [];
    }

    final result = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    final snapshot = await firestore
        .collection('shared_accounts')
        .where(FieldPath.documentId, whereIn: connectionIds)
        .get();

    for (final doc in snapshot.docs) {
      final members = _normalizeIds(doc.data()['members']);

      if (members.length != 2) {
        continue;
      }

      if (!members.contains(uid)) {
        continue;
      }

      final otherUid = members.firstWhere((id) => id != uid);

      if (otherUid == uid) {
        continue;
      }

      result.add(doc);
    }

    return result;
  }

  Future<int> _getActiveConnectionCount(String uid) async {
    final connections = await _getUserConnectionDocuments(uid);

    return connections.length;
  }

  Future<List<String>> _getActiveConnectionIdsForUser(String uid) async {
    final connections = await _getUserConnectionDocuments(uid);

    return connections.map((doc) => doc.id).toSet().toList();
  }

  Future<List<Map<String, dynamic>>> getActiveSharedAccounts() async {
    final uid = _currentUserId;

    final documents = await _getUserConnectionDocuments(uid);

    final unique = <String, Map<String, dynamic>>{};

    for (final doc in documents) {
      unique[doc.id] = {'id': doc.id, ...doc.data()};
    }

    return unique.values.toList();
  }

  Stream<List<Map<String, dynamic>>> watchActiveSharedAccounts() {
    final uid = _currentUserId;

    final mappingRef = firestore.collection('user_shared_accounts').doc(uid);

    return mappingRef.snapshots().asyncExpand((mappingSnapshot) {
      if (!mappingSnapshot.exists || mappingSnapshot.data() == null) {
        return Stream.value(<Map<String, dynamic>>[]);
      }

      final connectionIds = _extractConnectionIds(mappingSnapshot.data()!);

      if (connectionIds.isEmpty) {
        return Stream.value(<Map<String, dynamic>>[]);
      }

      return firestore
          .collection('shared_accounts')
          .where(FieldPath.documentId, whereIn: connectionIds)
          .snapshots()
          .map((snapshot) {
            final unique = <String, Map<String, dynamic>>{};

            for (final doc in snapshot.docs) {
              final data = doc.data();

              final members = _normalizeIds(data['members']);

              if (members.length != 2) {
                continue;
              }

              if (!members.contains(uid)) {
                continue;
              }

              final otherUid = members.firstWhere((id) => id != uid);

              if (otherUid == uid) {
                continue;
              }

              unique[doc.id] = {'id': doc.id, ...data};
            }

            return unique.values.toList();
          });
    });
  }

  Future<List<String>> getConnectedUserIds() async {
    final uid = _currentUserId;

    final connections = await getActiveSharedAccounts();

    final ids = <String>{uid};

    for (final connection in connections) {
      final members = _normalizeIds(connection['members']);

      for (final member in members) {
        if (member != uid) {
          ids.add(member);
        }
      }
    }

    return ids.toList();
  }

  Stream<List<String>> watchConnectedUserIds() {
    return watchActiveSharedAccounts().map((connections) {
      final uid = auth.currentUser?.uid ?? '';

      final ids = <String>{};

      if (uid.isNotEmpty) {
        ids.add(uid);
      }

      for (final connection in connections) {
        final members = _normalizeIds(connection['members']);

        for (final member in members) {
          if (member.isNotEmpty) {
            ids.add(member);
          }
        }
      }

      return ids.toList();
    });
  }

  Future<List<String>> getActiveConnectionIds() async {
    final connections = await getActiveSharedAccounts();

    return connections
        .map((connection) => connection['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Stream<List<String>> watchActiveConnectionIds() {
    return watchActiveSharedAccounts().map((connections) {
      return connections
          .map((connection) => connection['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    });
  }

  Future<List<String>> getConnectionMembers(String connectionId) async {
    final doc = await firestore
        .collection('shared_accounts')
        .doc(connectionId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return [_currentUserId];
    }

    final members = _normalizeIds(doc.data()!['members']);

    if (members.isEmpty) {
      return [_currentUserId];
    }

    return members;
  }

  Future<String?> getSharedAccountId() async {
    final ids = await getActiveConnectionIds();

    if (ids.isEmpty) {
      return null;
    }

    return ids.first;
  }

  Stream<String?> watchSharedAccountId() {
    return watchActiveConnectionIds().map((ids) {
      if (ids.isEmpty) {
        return null;
      }

      return ids.first;
    });
  }
}
