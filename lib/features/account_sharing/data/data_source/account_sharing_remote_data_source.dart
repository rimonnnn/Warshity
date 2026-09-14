import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';

class AccountSharingRemoteDataSource {
  AccountSharingRemoteDataSource(this.firestore, this.auth);

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const _sharedDataIdField = 'sharedDataId';

  static const _collections = ['clients', 'products', 'categories', 'invoices'];

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

  List<String> _normalizeUserIds(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Map<String, dynamic> _copyMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(source);
  }

  Map<String, dynamic> _withoutSharingFields(Map<String, dynamic> data) {
    final result = _copyMap(data);

    result.remove('userId');
    result.remove('userIds');
    result.remove('sharedAccountId');
    result.remove(_sharedDataIdField);

    return result;
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }

    if (value is GeoPoint) {
      return {'latitude': value.latitude, 'longitude': value.longitude};
    }

    if (value is DocumentReference) {
      return value.path;
    }

    if (value is List) {
      return value.map(_normalizeValue).toList();
    }

    if (value is Map) {
      final map = <String, dynamic>{};

      for (final entry in value.entries) {
        map[entry.key.toString()] = _normalizeValue(entry.value);
      }

      return map;
    }

    return value;
  }

  String _fingerprint(Map<String, dynamic> data) {
    final normalized = _normalizeValue(_withoutSharingFields(data));

    return jsonEncode(normalized);
  }

  // ignore: unused_element
  Future<List<String>> _getSharedMembers(String sharedAccountId) async {
    final snapshot = await firestore
        .collection('shared_accounts')
        .doc(sharedAccountId)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return [_currentUserId];
    }

    final members = _normalizeUserIds(snapshot.data()?['members']);

    if (!members.contains(_currentUserId)) {
      members.add(_currentUserId);
    }

    return members;
  }

  Future<void> _commitOperations(
    List<void Function(WriteBatch)> operations,
  ) async {
    const maxOperations = 400;

    for (var i = 0; i < operations.length; i += maxOperations) {
      final end = (i + maxOperations < operations.length)
          ? i + maxOperations
          : operations.length;

      final batch = firestore.batch();

      for (var j = i; j < end; j++) {
        operations[j](batch);
      }

      await batch.commit();
    }
  }

  Future<void> sendInvitation({required String email}) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final currentEmail = currentUser.email == null
        ? null
        : _normalizeEmail(currentUser.email!);

    final toEmail = _normalizeEmail(email);

    if (toEmail.isEmpty) {
      throw Exception('email_is_required'.tr());
    }

    if (currentEmail == null || currentEmail.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    if (currentEmail == toEmail) {
      throw Exception('cannot_invite_yourself'.tr());
    }

    final currentMapping = await firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid)
        .get();

    if (currentMapping.exists && currentMapping.data() != null) {
      final sharedAccountId = currentMapping
          .data()?['sharedAccountId']
          ?.toString();

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final sharedAccount = await firestore
            .collection('shared_accounts')
            .doc(sharedAccountId)
            .get();

        if (sharedAccount.exists && sharedAccount.data() != null) {
          final emails =
              (sharedAccount.data()?['emails'] as List?)
                  ?.map((e) => _normalizeEmail(e.toString()))
                  .where((e) => e.isNotEmpty)
                  .toList() ??
              [];

          if (emails.contains(toEmail)) {
            throw Exception('already_connected_to_this_account'.tr());
          }
        }
      }
    }

    final pendingSent = await firestore
        .collection('account_shares')
        .where('fromUid', isEqualTo: currentUser.uid)
        .where('toEmail', isEqualTo: toEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (pendingSent.docs.isNotEmpty) {
      throw Exception('invitation_already_pending'.tr());
    }

    final pendingReceived = await firestore
        .collection('account_shares')
        .where('toEmail', isEqualTo: currentEmail)
        .where('fromEmail', isEqualTo: toEmail)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (pendingReceived.docs.isNotEmpty) {
      throw Exception('invitation_already_pending'.tr());
    }

    await firestore.collection('account_shares').add({
      'fromUid': currentUser.uid,
      'fromEmail': currentEmail,
      'toEmail': toEmail,
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShareInvitationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
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

  Future<Map<String, String>> _deduplicateCollection({
    required String collectionName,
    required List<String> members,
    Map<String, dynamic> Function(Map<String, dynamic>)? transform,
  }) async {
    final snapshot = await firestore
        .collection(collectionName)
        .where('userId', whereIn: members)
        .get();

    final groups =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final doc in snapshot.docs) {
      final original = doc.data();
      final data = transform == null
          ? _copyMap(original)
          : transform(_copyMap(original));

      final sharedDataId = data[_sharedDataIdField]?.toString();

      final key = sharedDataId != null && sharedDataId.isNotEmpty
          ? 'shared:$sharedDataId'
          : 'fingerprint:${_fingerprint(data)}';

      groups.putIfAbsent(key, () => []).add(doc);
    }

    final operations = <void Function(WriteBatch)>[];
    final idMap = <String, String>{};

    for (final entry in groups.entries) {
      final docs = entry.value;

      docs.sort((a, b) {
        final aCreated = a.data()['createdAt']?.toString() ?? '';

        final bCreated = b.data()['createdAt']?.toString() ?? '';

        return aCreated.compareTo(bCreated);
      });

      final canonical = docs.first;
      final canonicalData = transform == null
          ? _copyMap(canonical.data())
          : transform(_copyMap(canonical.data()));

      final canonicalSharedDataId = canonicalData[_sharedDataIdField]
          ?.toString();

      canonicalData['userIds'] = members;
      canonicalData['sharedAccountId'] = _currentPendingSharedAccountId!;
      canonicalData[_sharedDataIdField] =
          (canonicalSharedDataId != null && canonicalSharedDataId.isNotEmpty)
          ? canonicalSharedDataId
          : canonical.id;

      operations.add((batch) => batch.set(canonical.reference, canonicalData));

      for (final duplicate in docs.skip(1)) {
        idMap[duplicate.id] = canonical.id;

        operations.add((batch) => batch.delete(duplicate.reference));
      }
    }

    await _commitOperations(operations);

    return idMap;
  }

  String? _currentPendingSharedAccountId;

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

    final snapshot = await invitationRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('invitation_not_found'.tr());
    }

    final data = snapshot.data()!;

    final toEmail = data['toEmail']?.toString().trim().toLowerCase();

    final status = data['status']?.toString();

    final fromUid = data['fromUid']?.toString();

    if (toEmail != _normalizeEmail(currentUser.email!)) {
      throw Exception('unauthorized_invitation'.tr());
    }

    if (status != 'pending') {
      throw Exception('invitation_no_longer_pending'.tr());
    }

    if (fromUid == null || fromUid.isEmpty) {
      throw Exception('invalid_invitation'.tr());
    }

    if (!accept) {
      await invitationRef.update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    final sharedAccountId = invitationId;

    final members = {fromUid, currentUser.uid}.toList();

    _currentPendingSharedAccountId = sharedAccountId;

    try {
      final clientMap = await _deduplicateCollection(
        collectionName: 'clients',
        members: members,
      );

      final productMap = await _deduplicateCollection(
        collectionName: 'products',
        members: members,
      );

      Map<String, dynamic> invoiceTransform(Map<String, dynamic> source) {
        final data = _copyMap(source);

        final customerId = data['customerId']?.toString();

        if (customerId != null && clientMap.containsKey(customerId)) {
          data['customerId'] = clientMap[customerId];
        }

        final items = data['items'];

        if (items is List) {
          final updatedItems = <dynamic>[];

          for (final item in items) {
            if (item is Map) {
              final itemMap = Map<String, dynamic>.from(item);

              final productId = itemMap['productId']?.toString();

              if (productId != null && productMap.containsKey(productId)) {
                itemMap['productId'] = productMap[productId];
              }

              updatedItems.add(itemMap);
            } else {
              updatedItems.add(item);
            }
          }

          data['items'] = updatedItems;
        }

        return data;
      }

      await _deduplicateCollection(
        collectionName: 'categories',
        members: members,
      );

      await _deduplicateCollection(
        collectionName: 'invoices',
        members: members,
        transform: invoiceTransform,
      );

      final sharedAccountRef = firestore
          .collection('shared_accounts')
          .doc(sharedAccountId);

      final ownerAccessRef = firestore
          .collection('user_shared_accounts')
          .doc(fromUid);

      final currentAccessRef = firestore
          .collection('user_shared_accounts')
          .doc(currentUser.uid);

      await sharedAccountRef.set({
        'members': members,
        'emails': [
          _normalizeEmail(currentUser.email!),
          _normalizeEmail(data['fromEmail']?.toString() ?? ''),
        ],
        'invitationId': invitationId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await Future.wait([
        ownerAccessRef.set({
          'sharedAccountId': sharedAccountId,
          'members': members,
          'invitationId': invitationId,
          'createdAt': FieldValue.serverTimestamp(),
        }),
        currentAccessRef.set({
          'sharedAccountId': sharedAccountId,
          'members': members,
          'invitationId': invitationId,
          'createdAt': FieldValue.serverTimestamp(),
        }),
      ]);

      await invitationRef.update({
        'status': 'accepted',
        'sharedAccountId': sharedAccountId,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } finally {
      _currentPendingSharedAccountId = null;
    }
  }

  Future<String?> getSharedAccountId() async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return null;
    }

    final snapshot = await firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    final id = snapshot.data()?['sharedAccountId']?.toString();

    if (id == null || id.isEmpty) {
      return null;
    }

    return id;
  }

  Stream<String?> watchSharedAccountId() async* {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      yield null;
      return;
    }

    final ref = firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid);

    await for (final snapshot in ref.snapshots()) {
      if (!snapshot.exists || snapshot.data() == null) {
        yield null;
        continue;
      }

      final id = snapshot.data()?['sharedAccountId']?.toString();

      yield id == null || id.isEmpty ? null : id;
    }
  }

  Future<void> deleteSharedAccount() async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final mappingSnapshot = await firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid)
        .get();

    if (!mappingSnapshot.exists || mappingSnapshot.data() == null) {
      throw Exception('shared_account_not_found'.tr());
    }

    final mappingData = mappingSnapshot.data()!;

    final sharedAccountId = mappingData['sharedAccountId']?.toString();

    final members = _normalizeUserIds(mappingData['members']);

    if (sharedAccountId == null ||
        sharedAccountId.isEmpty ||
        members.length != 2) {
      throw Exception('shared_account_not_found'.tr());
    }

    final memberA = members[0];
    final memberB = members[1];

    final collections = ['clients', 'products', 'categories', 'invoices'];

    final snapshots =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final collectionName in collections) {
      final snapshot = await firestore
          .collection(collectionName)
          .where('sharedAccountId', isEqualTo: sharedAccountId)
          .get();

      snapshots[collectionName] = snapshot.docs;
    }

    final clientMapA = <String, String>{};
    final clientMapB = <String, String>{};

    final productMapA = <String, String>{};
    final productMapB = <String, String>{};

    final operations = <void Function(WriteBatch)>[];

    String getLogicalKey(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final data = doc.data();

      final sharedDataId = data[_sharedDataIdField]?.toString();

      if (sharedDataId != null && sharedDataId.isNotEmpty) {
        return 'shared:$sharedDataId';
      }

      final invoiceId = data['invoiceId']?.toString();

      if (invoiceId != null && invoiceId.isNotEmpty) {
        return 'invoice:$invoiceId';
      }

      return 'fingerprint:${_fingerprint(data)}';
    }

    for (final collectionName in ['clients', 'products', 'categories']) {
      final docs = snapshots[collectionName] ?? [];

      final groups =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

      for (final doc in docs) {
        final key = getLogicalKey(doc);

        groups.putIfAbsent(key, () => []).add(doc);
      }

      for (final group in groups.values) {
        if (group.isEmpty) {
          continue;
        }

        group.sort((a, b) {
          final aId = a.id;
          final bId = b.id;
          return aId.compareTo(bId);
        });

        final canonical = group.first;
        final originalData = _copyMap(canonical.data());

        final sharedDataId =
            originalData[_sharedDataIdField]?.toString() ?? canonical.id;

        final dataForA = _copyMap(originalData);

        dataForA['userId'] = memberA;
        dataForA['userIds'] = [memberA];
        dataForA[_sharedDataIdField] = sharedDataId;
        dataForA.remove('sharedAccountId');

        operations.add((batch) => batch.set(canonical.reference, dataForA));

        final copyForBRef = firestore.collection(collectionName).doc();

        final dataForB = _copyMap(originalData);

        dataForB['userId'] = memberB;
        dataForB['userIds'] = [memberB];
        dataForB[_sharedDataIdField] = sharedDataId;
        dataForB.remove('sharedAccountId');

        operations.add((batch) => batch.set(copyForBRef, dataForB));

        if (collectionName == 'clients') {
          for (final doc in group) {
            clientMapA[doc.id] = canonical.id;
            clientMapB[doc.id] = copyForBRef.id;
          }
        }

        if (collectionName == 'products') {
          for (final doc in group) {
            productMapA[doc.id] = canonical.id;
            productMapB[doc.id] = copyForBRef.id;
          }
        }

        for (final duplicate in group.skip(1)) {
          operations.add((batch) => batch.delete(duplicate.reference));
        }
      }
    }

    final invoiceDocs = snapshots['invoices'] ?? [];

    final invoiceGroups =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final doc in invoiceDocs) {
      final key = getLogicalKey(doc);

      invoiceGroups.putIfAbsent(key, () => []).add(doc);
    }

    for (final group in invoiceGroups.values) {
      if (group.isEmpty) {
        continue;
      }

      group.sort((a, b) {
        final aId = a.id;
        final bId = b.id;
        return aId.compareTo(bId);
      });

      final canonical = group.first;

      final originalData = _copyMap(canonical.data());

      final sharedDataId =
          originalData[_sharedDataIdField]?.toString() ?? canonical.id;

      String? originalCustomerId = originalData['customerId']?.toString();

      if (originalCustomerId != null) {
        originalCustomerId =
            clientMapA[originalCustomerId] ?? originalCustomerId;
      }

      List<dynamic> mapItems(dynamic items, Map<String, String> productMap) {
        if (items is! List) {
          return [];
        }

        return items.map((item) {
          if (item is! Map) {
            return item;
          }

          final itemMap = Map<String, dynamic>.from(item);

          final productId = itemMap['productId']?.toString();

          if (productId != null) {
            itemMap['productId'] = productMap[productId] ?? productId;
          }

          return itemMap;
        }).toList();
      }

      final dataForA = _copyMap(originalData);

      dataForA['userId'] = memberA;
      dataForA['userIds'] = [memberA];
      dataForA['sharedDataId'] = sharedDataId;
      dataForA['invoiceId'] = canonical.id;

      if (originalCustomerId != null) {
        dataForA['customerId'] = originalCustomerId;
      }

      if (originalData['items'] is List) {
        dataForA['items'] = mapItems(originalData['items'], productMapA);
      }

      dataForA.remove('sharedAccountId');

      operations.add((batch) => batch.set(canonical.reference, dataForA));

      final copyForBRef = firestore.collection('invoices').doc();

      final dataForB = _copyMap(originalData);

      dataForB['userId'] = memberB;
      dataForB['userIds'] = [memberB];
      dataForB['sharedDataId'] = sharedDataId;
      dataForB['invoiceId'] = copyForBRef.id;

      if (originalCustomerId != null) {
        dataForB['customerId'] =
            clientMapB[originalCustomerId] ?? originalCustomerId;
      }

      if (originalData['items'] is List) {
        dataForB['items'] = mapItems(originalData['items'], productMapB);
      }

      dataForB.remove('sharedAccountId');

      operations.add((batch) => batch.set(copyForBRef, dataForB));

      for (final duplicate in group.skip(1)) {
        operations.add((batch) => batch.delete(duplicate.reference));
      }
    }

    await _commitOperations(operations);

    await Future.wait(
      members.map(
        (memberUid) => firestore
            .collection('user_shared_accounts')
            .doc(memberUid)
            .delete(),
      ),
    );

    await firestore.collection('shared_accounts').doc(sharedAccountId).delete();
  }
}
