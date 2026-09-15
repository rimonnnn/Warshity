import '../data_source/account_sharing_remote_data_source.dart';
import '../models/share_invitation_model.dart';

class AccountSharingRepository {
  AccountSharingRepository(this.remoteDataSource);

  final AccountSharingRemoteDataSource remoteDataSource;

  Future<void> sendInvitation({required String email}) {
    return remoteDataSource.sendInvitation(email: email);
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    return remoteDataSource.watchReceivedInvitations();
  }

  Stream<Map<String, String>> watchSentInvitationStatuses() {
    return remoteDataSource.watchSentInvitationStatuses();
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) {
    return remoteDataSource.respondToInvitation(
      invitationId: invitationId,
      accept: accept,
    );
  }

  Future<List<Map<String, dynamic>>> getActiveSharedAccounts() {
    return remoteDataSource.getActiveSharedAccounts();
  }

  Stream<List<Map<String, dynamic>>> watchActiveSharedAccounts() {
    return remoteDataSource.watchActiveSharedAccounts();
  }

  Future<List<String>> getActiveConnectionIds() {
    return remoteDataSource.getActiveConnectionIds();
  }

  Stream<List<String>> watchActiveConnectionIds() {
    return remoteDataSource.watchActiveConnectionIds();
  }

  Future<List<String>> getConnectedUserIds() {
    return remoteDataSource.getConnectedUserIds();
  }

  Stream<List<String>> watchConnectedUserIds() {
    return remoteDataSource.watchConnectedUserIds();
  }

  Future<List<String>> getConnectionMembers(String connectionId) {
    return remoteDataSource.getConnectionMembers(connectionId);
  }

  Future<void> deleteSharedAccount(String connectionId) {
    return remoteDataSource.deleteSharedAccount(connectionId);
  }

  Future<String?> getSharedAccountId() {
    return remoteDataSource.getSharedAccountId();
  }

  Stream<String?> watchSharedAccountId() {
    return remoteDataSource.watchSharedAccountId();
  }
}
