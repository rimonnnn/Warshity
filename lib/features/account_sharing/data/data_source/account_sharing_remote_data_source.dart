import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';

class AccountSharingRemoteDataSource {
  AccountSharingRemoteDataSource(this.firestore, this.auth);

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  Future<void> sendInvitation({required String email}) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final toEmail = email.trim().toLowerCase();

    if (toEmail.isEmpty) {
      throw Exception('email_is_required'.tr());
    }

    final currentEmail = currentUser.email?.trim().toLowerCase();

    if (currentEmail == toEmail) {
      throw Exception('cannot_invite_yourself'.tr());
    }

    final currentMappingSnapshot = await firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid)
        .get();

    if (currentMappingSnapshot.exists &&
        currentMappingSnapshot.data() != null) {
      final mappingData = currentMappingSnapshot.data()!;

      final sharedAccountId = mappingData['sharedAccountId']?.toString();

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final sharedAccountSnapshot = await firestore
            .collection('shared_accounts')
            .doc(sharedAccountId)
            .get();

        if (sharedAccountSnapshot.exists &&
            sharedAccountSnapshot.data() != null) {
          final sharedData = sharedAccountSnapshot.data()!;

          final members = (sharedData['members'] as List? ?? [])
              .map((e) => e.toString())
              .toList();

          final otherUid = members.firstWhere(
            (uid) => uid != currentUser.uid,
            orElse: () => '',
          );

          if (otherUid.isNotEmpty) {
            final invitationSnapshot = await firestore
                .collection('account_shares')
                .doc(sharedAccountId)
                .get();

            if (invitationSnapshot.exists &&
                invitationSnapshot.data() != null) {
              final invitationData = invitationSnapshot.data()!;

              final fromEmail = invitationData['fromEmail']
                  ?.toString()
                  .trim()
                  .toLowerCase();

              final existingToEmail = invitationData['toEmail']
                  ?.toString()
                  .trim()
                  .toLowerCase();

              if (toEmail == fromEmail || toEmail == existingToEmail) {
                throw Exception('already_connected_to_this_account'.tr());
              }
            }
          }
        }
      }
    }

    await firestore.collection('account_shares').add({
      'fromUid': currentUser.uid,
      'fromEmail': currentUser.email ?? '',
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

    final email = currentUser.email!.toLowerCase();

    return firestore
        .collection('account_shares')
        .where('toEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ShareInvitationModel.fromMap(doc.id, doc.data());
          }).toList();
        });
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

    final snapshot = await invitationRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('invitation_not_found'.tr());
    }

    final data = snapshot.data()!;

    final toEmail = data['toEmail']?.toString().trim().toLowerCase();

    final status = data['status']?.toString();

    final fromUid = data['fromUid']?.toString();

    if (toEmail != currentUser.email!.trim().toLowerCase()) {
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

    final members = [fromUid, currentUser.uid];

    final sharedAccountRef = firestore
        .collection('shared_accounts')
        .doc(sharedAccountId);

    final ownerAccessRef = firestore
        .collection('user_shared_accounts')
        .doc(fromUid);

    final currentUserAccessRef = firestore
        .collection('user_shared_accounts')
        .doc(currentUser.uid);

    await sharedAccountRef.set({
      'members': members,
      'emails': [
        currentUser.email!.trim().toLowerCase(),
        (data['fromEmail']?.toString() ?? '').trim().toLowerCase(),
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

      currentUserAccessRef.set({
        'sharedAccountId': sharedAccountId,
        'members': members,
        'invitationId': invitationId,
        'createdAt': FieldValue.serverTimestamp(),
      }),
    ]);

    await Future.wait([
      _addSharedAccountIdToUserData(
        userId: fromUid,
        sharedAccountId: sharedAccountId,
      ),

      _addSharedAccountIdToUserData(
        userId: currentUser.uid,
        sharedAccountId: sharedAccountId,
      ),
    ]);

    await invitationRef.update({
      'status': 'accepted',
      'sharedAccountId': sharedAccountId,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addSharedAccountIdToUserData({
    required String userId,
    required String sharedAccountId,
  }) async {
    const collections = ['clients', 'products', 'categories', 'invoices'];

    for (final collectionName in collections) {
      final snapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        continue;
      }

      const batchLimit = 400;

      for (var i = 0; i < snapshot.docs.length; i += batchLimit) {
        final batch = firestore.batch();

        final end = (i + batchLimit < snapshot.docs.length)
            ? i + batchLimit
            : snapshot.docs.length;

        for (var j = i; j < end; j++) {
          batch.update(snapshot.docs[j].reference, {
            'sharedAccountId': sharedAccountId,
          });
        }

        await batch.commit();
      }
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

    return snapshot.data()?['sharedAccountId']?.toString();
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

    final initialSnapshot = await ref.get();

    if (!initialSnapshot.exists || initialSnapshot.data() == null) {
      print('SHARED ACCOUNT INITIAL => NULL');
      yield null;
    } else {
      final sharedAccountId = initialSnapshot
          .data()?['sharedAccountId']
          ?.toString();

      print('SHARED ACCOUNT INITIAL => $sharedAccountId');

      yield sharedAccountId;
    }

    await for (final snapshot in ref.snapshots(includeMetadataChanges: true)) {
      if (!snapshot.exists || snapshot.data() == null) {
        print('SHARED ACCOUNT STREAM => NULL');
        yield null;
        continue;
      }

      final sharedAccountId = snapshot.data()?['sharedAccountId']?.toString();

      print(
        'SHARED ACCOUNT STREAM => $sharedAccountId '
        'FROM CACHE: ${snapshot.metadata.isFromCache}',
      );

      yield sharedAccountId;
    }
  }

  Future<void> deleteSharedAccount() async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('user_not_authenticated'.tr());
    }

    final currentUid = currentUser.uid;

    final currentMappingRef = firestore
        .collection('user_shared_accounts')
        .doc(currentUid);

    final currentMappingSnapshot = await currentMappingRef.get();

    if (!currentMappingSnapshot.exists ||
        currentMappingSnapshot.data() == null) {
      throw Exception('shared_account_not_found'.tr());
    }

    final mappingData = currentMappingSnapshot.data()!;

    final sharedAccountId = mappingData['sharedAccountId']?.toString();

    final membersData = mappingData['members'];

    if (sharedAccountId == null || sharedAccountId.isEmpty) {
      throw Exception('shared_account_not_found'.tr());
    }

    if (membersData is! List || membersData.length < 2) {
      throw Exception('shared_account_not_found'.tr());
    }

    final members = membersData
        .map((e) => e.toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    const collections = ['clients', 'products', 'categories', 'invoices'];

    for (final collectionName in collections) {
      final snapshot = await firestore
          .collection(collectionName)
          .where('sharedAccountId', isEqualTo: sharedAccountId)
          .get();

      if (snapshot.docs.isEmpty) {
        continue;
      }

      const batchLimit = 400;

      for (var i = 0; i < snapshot.docs.length; i += batchLimit) {
        final batch = firestore.batch();

        final end = (i + batchLimit < snapshot.docs.length)
            ? i + batchLimit
            : snapshot.docs.length;

        for (var j = i; j < end; j++) {
          batch.update(snapshot.docs[j].reference, {
            'sharedAccountId': FieldValue.delete(),
          });
        }

        await batch.commit();
      }
    }

    for (final memberUid in members) {
      await firestore
          .collection('user_shared_accounts')
          .doc(memberUid)
          .delete();
    }

    await firestore.collection('shared_accounts').doc(sharedAccountId).delete();
  }
}
