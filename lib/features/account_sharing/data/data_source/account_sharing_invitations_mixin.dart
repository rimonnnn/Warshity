part of 'account_sharing_remote_data_source.dart';

/// Sending and watching share invitations.
mixin _AccountSharingInvitations
    on _AccountSharingCore, _AccountSharingConnections {
  Future<void> sendInvitation({required String email}) async {
    // Prevent invitation operations while account sharing is disabled.
    if (!FeatureFlags.accountSharingEnabled) {
      throw StateError('Account sharing is temporarily disabled.');
    }

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

    if (currentCount >= _maxConnections) {
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

      if (targetCount >= _maxConnections) {
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
    if (!FeatureFlags.accountSharingEnabled) {
      return Stream<List<ShareInvitationModel>>.value(<ShareInvitationModel>[]);
    }

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
    if (!FeatureFlags.accountSharingEnabled) {
      return Stream<Map<String, String>>.value(<String, String>{});
    }

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
}
