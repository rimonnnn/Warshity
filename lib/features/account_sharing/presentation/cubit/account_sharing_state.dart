abstract class AccountSharingState {}

class AccountSharingInitial extends AccountSharingState {}

class AccountSharingLoading extends AccountSharingState {
  final String? action;
  final String? itemId;

  AccountSharingLoading({this.action, this.itemId});
}

class AccountInvitationSent extends AccountSharingState {}

class AccountInvitationAccepted extends AccountSharingState {}

class AccountInvitationRejected extends AccountSharingState {}

class AccountInvitationAcceptedRemotely extends AccountSharingState {}

class AccountInvitationRejectedRemotely extends AccountSharingState {}

class AccountInvitationReceivedRemotely extends AccountSharingState {}

class AccountSharedAccountDeleted extends AccountSharingState {}

class AccountSharedAccountDeletedRemotely extends AccountSharingState {}

class AccountSharingError extends AccountSharingState {
  final String message;

  AccountSharingError(this.message);
}

class AccountSharingStatusChanged extends AccountSharingState {
  final String? sharedAccountId;

  AccountSharingStatusChanged({required this.sharedAccountId});
}
