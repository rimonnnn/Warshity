part of 'account_sharing_remote_data_source.dart';

/// Accepting / rejecting invitations.
mixin _AccountSharingRespond on _AccountSharingCore, _AccountSharingConnections, _AccountSharingMerge {
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

    if (senderCount >= _maxConnections || receiverCount >= _maxConnections) {
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

      if (senderIds.length >= _maxConnections ||
          receiverIds.length >= _maxConnections) {
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
}
