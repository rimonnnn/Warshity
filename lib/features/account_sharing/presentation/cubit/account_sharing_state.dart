abstract class AccountSharingState {}

class AccountSharingInitial
    extends AccountSharingState {}

class AccountSharingLoading
    extends AccountSharingState {}

class AccountInvitationSent
    extends AccountSharingState {}

class AccountInvitationResponded
    extends AccountSharingState {}

class AccountSharedAccountDeleted
    extends AccountSharingState {}

class AccountSharingError
    extends AccountSharingState {
  final String message;

  AccountSharingError(this.message);
}
class AccountSharingStatusChanged extends AccountSharingState {
  final String? sharedAccountId;

  AccountSharingStatusChanged({
    required this.sharedAccountId,
  });
}