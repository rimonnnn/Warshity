import 'package:warshity/core/config/feature_flags.dart';

import '../data_source/account_sharing_remote_data_source.dart';
import '../models/share_invitation_model.dart';

class AccountSharingRepository {
  AccountSharingRepository(this.remoteDataSource);

  final AccountSharingRemoteDataSource remoteDataSource;

  static const String _disabledMessage =
      'Account sharing is temporarily disabled.';

  void _ensureEnabled() {
    if (!FeatureFlags.accountSharingEnabled) {
      throw StateError(_disabledMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // Invitations
  // ---------------------------------------------------------------------------

  Future<void> sendInvitation({required String email}) async {
    _ensureEnabled();

    await remoteDataSource.sendInvitation(email: email);
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<List<ShareInvitationModel>>.empty();
    }

    return remoteDataSource.watchReceivedInvitations();
  }

  Stream<Map<String, String>> watchSentInvitationStatuses() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<Map<String, String>>.empty();
    }

    return remoteDataSource.watchSentInvitationStatuses();
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    _ensureEnabled();

    await remoteDataSource.respondToInvitation(
      invitationId: invitationId,
      accept: accept,
    );
  }

  // ---------------------------------------------------------------------------
  // Shared accounts
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getActiveSharedAccounts() async {
    if (!FeatureFlags.accountSharingEnabled) {
      return [];
    }

    return remoteDataSource.getActiveSharedAccounts();
  }

  Stream<List<Map<String, dynamic>>> watchActiveSharedAccounts() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }

    return remoteDataSource.watchActiveSharedAccounts();
  }

  Future<List<String>> getActiveConnectionIds() async {
    if (!FeatureFlags.accountSharingEnabled) {
      return [];
    }

    return remoteDataSource.getActiveConnectionIds();
  }

  Stream<List<String>> watchActiveConnectionIds() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<List<String>>.empty();
    }

    return remoteDataSource.watchActiveConnectionIds();
  }

  Future<List<String>> getConnectedUserIds() async {
    if (!FeatureFlags.accountSharingEnabled) {
      return [];
    }

    return remoteDataSource.getConnectedUserIds();
  }

  Stream<List<String>> watchConnectedUserIds() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<List<String>>.empty();
    }

    return remoteDataSource.watchConnectedUserIds();
  }

  Future<List<String>> getConnectionMembers(String connectionId) async {
    if (!FeatureFlags.accountSharingEnabled) {
      return [];
    }

    return remoteDataSource.getConnectionMembers(connectionId);
  }

  Future<void> deleteSharedAccount(String connectionId) async {
    _ensureEnabled();

    await remoteDataSource.deleteSharedAccount(connectionId);
  }

  // ---------------------------------------------------------------------------
  // Shared account ID
  // ---------------------------------------------------------------------------

  Future<String?> getSharedAccountId() async {
    if (!FeatureFlags.accountSharingEnabled) {
      return null;
    }

    return remoteDataSource.getSharedAccountId();
  }

  Stream<String?> watchSharedAccountId() {
    if (!FeatureFlags.accountSharingEnabled) {
      return const Stream<String?>.empty();
    }

    return remoteDataSource.watchSharedAccountId();
  }
}
