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

  Stream<List<ShareInvitationModel>> watchSentInvitationsStatus() {
    return remoteDataSource.watchSentInvitationsStatus();
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

  Future<String?> getSharedAccountId() {
    return remoteDataSource.getSharedAccountId();
  }

  Stream<String?> watchSharedAccountId() {
    return remoteDataSource.watchSharedAccountId();
  }

  Future<void> deleteSharedAccount() {
    return remoteDataSource.deleteSharedAccount();
  }
}
