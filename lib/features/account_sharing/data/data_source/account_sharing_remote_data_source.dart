import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';

class AccountSharingRemoteDataSource {
  AccountSharingRemoteDataSource(this.firestore, this.auth);

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const int maxConnections = 5;

  static const String _connectionIdsField = 'connectionIds';

  static const String _connectionsCountField = 'connectionsCount';

  static const String _sharedConnectionIdsField = 'sharedConnectionIds';

  static const String _inheritedFromConnectionsField =
      'inheritedFromConnections';

  static const List<String> _dataCollections = [
    'clients',
    'products',
    'categories',
    'invoices',
  ];

  String get _currentUserId {
    final uid = auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  String _normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  List<String> _normalizeIds(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _extractConnectionIds(Map<String, dynamic> data) {
    final value = data[_connectionIdsField];

    if (value is List) {
      return _normalizeIds(value);
    }

    final legacy = data['sharedAccountId'];

    if (legacy is String && legacy.isNotEmpty) {
      return [legacy];
    }

    if (legacy is List) {
      return _normalizeIds(legacy);
    }

    return <String>[];
  }

  String _getLogicalDataId(Map<String, dynamic> data, String documentId) {
    final sharedDataId = data['sharedDataId']?.toString().trim();

    if (sharedDataId != null && sharedDataId.isNotEmpty) {
      return sharedDataId;
    }

    return documentId;
  }

  String _safeId(String value) {
    final result = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    if (result.isEmpty) {
      return 'data';
    }

    return result;
  }

  String _getSeparatedDocumentId({
    required String collectionName,
    required String logicalDataId,
    required String uid,
  }) {
    final id = 'separated_${collectionName}_${_safeId(logicalDataId)}_$uid';

    if (id.length <= 1500) {
      return id;
    }

    return id.substring(0, 1500);
  }

  DateTime? _getUpdatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  QueryDocumentSnapshot<Map<String, dynamic>> _selectCanonicalDocument({
    required QueryDocumentSnapshot<Map<String, dynamic>> firstDoc,
    required QueryDocumentSnapshot<Map<String, dynamic>> secondDoc,
  }) {
    final firstUpdatedAt = _getUpdatedAt(firstDoc.data()['updatedAt']);

    final secondUpdatedAt = _getUpdatedAt(secondDoc.data()['updatedAt']);

    if (firstUpdatedAt == null && secondUpdatedAt == null) {
      return firstDoc;
    }

    if (firstUpdatedAt == null) {
      return secondDoc;
    }

    if (secondUpdatedAt == null) {
      return firstDoc;
    }

    return firstUpdatedAt.isAfter(secondUpdatedAt) ? firstDoc : secondDoc;
  }

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

  Future<void> sendInvitation({required String email}) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final currentEmail = currentUser.email == null
        ? ''
        : _normalizeEmail(currentUser.email!);

    final targetEmail = _normalizeEmail(email);

    if (targetEmail.isEmpty) {
      throw Exception('email_is_required'.tr());
    }

    if (currentEmail.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    if (currentEmail == targetEmail) {
      throw Exception('cannot_invite_yourself'.tr());
    }

    final currentCount = await _getActiveConnectionCount(currentUser.uid);

    if (currentCount >= maxConnections) {
      throw Exception('maximum_connections_reached'.tr());
    }

    final targetSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: targetEmail)
        .limit(1)
        .get();

    if (targetSnapshot.docs.isNotEmpty) {
      final targetUid = targetSnapshot.docs.first.id;

      if (targetUid == currentUser.uid) {
        throw Exception('cannot_invite_yourself'.tr());
      }

      final targetCount = await _getActiveConnectionCount(targetUid);

      if (targetCount >= maxConnections) {
        throw Exception('maximum_connections_reached'.tr());
      }

      final existingConnections = await _getUserConnectionDocuments(
        currentUser.uid,
      );

      for (final connection in existingConnections) {
        final members = _normalizeIds(connection.data()['members']);

        if (members.contains(targetUid)) {
          throw Exception('already_connected_to_this_account'.tr());
        }
      }
    }

    final pendingSent = await firestore
        .collection('account_shares')
        .where('fromUid', isEqualTo: currentUser.uid)
        .where('toEmail', isEqualTo: targetEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (pendingSent.docs.isNotEmpty) {
      throw Exception('invitation_already_pending'.tr());
    }

    final pendingReceived = await firestore
        .collection('account_shares')
        .where('toEmail', isEqualTo: currentEmail)
        .where('fromEmail', isEqualTo: targetEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (pendingReceived.docs.isNotEmpty) {
      throw Exception('invitation_already_pending'.tr());
    }

    await firestore.collection('account_shares').add({
      'fromUid': currentUser.uid,
      'fromEmail': currentEmail,
      'toEmail': targetEmail,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    final currentUser = auth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      return Stream.value([]);
    }

    final email = _normalizeEmail(currentUser.email!);

    return firestore
        .collection('account_shares')
        .where('toEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ShareInvitationModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Stream<Map<String, String>> watchSentInvitationStatuses() {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return Stream.value({});
    }

    return firestore
        .collection('account_shares')
        .where('fromUid', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          final result = <String, String>{};

          for (final doc in snapshot.docs) {
            final status = doc.data()['status']?.toString();

            if (status != null && status.isNotEmpty) {
              result[doc.id] = status;
            }
          }

          return result;
        });
  }

  bool _canShareRecordToConnection({
    required Map<String, dynamic> data,
    required String connectionId,
    required bool hadOtherConnectionsBeforeLink,
  }) {
    if (!hadOtherConnectionsBeforeLink) {
      return true;
    }

    final inherited = _normalizeIds(data[_inheritedFromConnectionsField]);

    if (inherited.isEmpty) {
      return true;
    }

    return inherited.contains(connectionId);
  }

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

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    final currentUser = auth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final invitationRef = firestore
        .collection('account_shares')
        .doc(invitationId);

    final invitationSnapshot = await invitationRef.get();

    if (!invitationSnapshot.exists || invitationSnapshot.data() == null) {
      throw Exception('invitation_not_found'.tr());
    }

    final invitationData = invitationSnapshot.data()!;

    final toEmail = invitationData['toEmail']?.toString().trim().toLowerCase();

    final fromEmail = invitationData['fromEmail']
        ?.toString()
        .trim()
        .toLowerCase();

    final fromUid = invitationData['fromUid']?.toString();

    final status = invitationData['status']?.toString();

    if (toEmail != _normalizeEmail(currentUser.email!)) {
      throw Exception('unauthorized_invitation'.tr());
    }

    if (status != 'pending') {
      throw Exception('invitation_no_longer_pending'.tr());
    }

    if (fromUid == null || fromUid.isEmpty) {
      throw Exception('invalid_invitation'.tr());
    }

    if (fromUid == currentUser.uid) {
      throw Exception('cannot_connect_to_yourself'.tr());
    }

    if (!accept) {
      await invitationRef.update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    final senderCount = await _getActiveConnectionCount(fromUid);

    final receiverCount = await _getActiveConnectionCount(currentUser.uid);

    if (senderCount >= maxConnections || receiverCount >= maxConnections) {
      throw Exception('maximum_connections_reached'.tr());
    }

    final senderConnections = await _getUserConnectionDocuments(fromUid);

    for (final connection in senderConnections) {
      final members = _normalizeIds(connection.data()['members']);

      if (members.contains(currentUser.uid)) {
        throw Exception('already_connected_to_this_account'.tr());
      }
    }

    final connectionId = invitationId;

    final sharedAccountRef = firestore
        .collection('shared_accounts')
        .doc(connectionId);

    final senderMappingRef = firestore
        .collection('user_shared_accounts')
        .doc(fromUid);

    final receiverMappingRef = firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid);

    final members = [fromUid, currentUser.uid];

    final emails = [
      _normalizeEmail(fromEmail ?? ''),
      _normalizeEmail(currentUser.email!),
    ];

    final senderHadOtherConnections = senderCount > 0;

    final receiverHadOtherConnections = receiverCount > 0;

    await firestore.runTransaction((transaction) async {
      final senderMappingSnapshot = await transaction.get(senderMappingRef);

      final receiverMappingSnapshot = await transaction.get(receiverMappingRef);

      final senderIds =
          senderMappingSnapshot.exists && senderMappingSnapshot.data() != null
          ? _extractConnectionIds(senderMappingSnapshot.data()!)
          : <String>[];

      final receiverIds =
          receiverMappingSnapshot.exists &&
              receiverMappingSnapshot.data() != null
          ? _extractConnectionIds(receiverMappingSnapshot.data()!)
          : <String>[];

      if (senderIds.length >= maxConnections ||
          receiverIds.length >= maxConnections) {
        throw Exception('maximum_connections_reached'.tr());
      }

      if (!senderIds.contains(connectionId)) {
        senderIds.add(connectionId);
      }

      if (!receiverIds.contains(connectionId)) {
        receiverIds.add(connectionId);
      }

      transaction.set(sharedAccountRef, {
        'members': members,
        'emails': emails,
        'invitationId': invitationId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(senderMappingRef, {
        _connectionIdsField: senderIds,
        _connectionsCountField: senderIds.length,
      }, SetOptions(merge: true));

      transaction.set(receiverMappingRef, {
        _connectionIdsField: receiverIds,
        _connectionsCountField: receiverIds.length,
      }, SetOptions(merge: true));

      transaction.update(invitationRef, {
        'status': 'accepted',
        'sharedAccountId': connectionId,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    });

    await _mergeDataForConnection(
      firstUid: fromUid,
      secondUid: currentUser.uid,
      connectionId: connectionId,
      firstHadOtherConnections: senderHadOtherConnections,
      secondHadOtherConnections: receiverHadOtherConnections,
    );

    await Future.wait([
      _addConnectionToUserData(
        ownerUid: fromUid,
        connectionId: connectionId,
        hadOtherConnectionsBeforeLink: senderHadOtherConnections,
      ),
      _addConnectionToUserData(
        ownerUid: currentUser.uid,
        connectionId: connectionId,
        hadOtherConnectionsBeforeLink: receiverHadOtherConnections,
      ),
    ]);
  }

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

    for (final collectionName in _dataCollections) {
      final snapshot = await firestore
          .collection(collectionName)
          .where(_sharedConnectionIdsField, arrayContains: connectionId)
          .get();

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

          batch.set(otherCopyRef, otherCopyData);

          for (final oldDoc in snapshot.docs.where(
            (doc) => _getLogicalDataId(doc.data(), doc.id) == logicalDataId,
          )) {
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

  Future<void> _removeConnectionFromUserMapping({
    required String uid,
    required String connectionId,
  }) async {
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

  int _cachedConnectionsCount = 0;

  int getActiveConnectionsCount() {
    return _cachedConnectionsCount;
  }

  void updateConnectionsCount(int count) {
    _cachedConnectionsCount = count;
  }
}
