import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class AccountSharingCubit extends Cubit<AccountSharingState> {
  AccountSharingCubit(this.repository) : super(AccountSharingInitial()) {
    _startWatching();
  }

  final AccountSharingRepository repository;

  StreamSubscription<String?>? _sharedAccountSubscription;
  StreamSubscription<List<ShareInvitationModel>>? _sentInvitationsSubscription;

  String? _sharedAccountId;
  String? _previousSharedAccountId;
  bool _sharedAccountInitialized = false;

  final Map<String, String> _previousInvitationStatuses = {};
  bool _sentInvitationsInitialized = false;

  bool _isLocalAccepting = false;
  bool _isLocalRejecting = false;
  bool _isLocalDeleting = false;

  String? get sharedAccountId => _sharedAccountId;

  bool get isShared => _sharedAccountId != null;

  void _startWatching() {
    _startWatchingSharedAccount();
    _startWatchingSentInvitations();
  }

  void _startWatchingSharedAccount() {
    _sharedAccountSubscription?.cancel();

    _sharedAccountSubscription =
        repository.watchSharedAccountId().listen(
      (sharedAccountId) {
        _sharedAccountId = sharedAccountId;

        if (!_sharedAccountInitialized) {
          _previousSharedAccountId = sharedAccountId;
          _sharedAccountInitialized = true;
          return;
        }

        final previousId = _previousSharedAccountId;
        _previousSharedAccountId = sharedAccountId;

        if (previousId != null && sharedAccountId == null) {
          if (_isLocalDeleting) {
            _isLocalDeleting = false;
            return;
          }
          emit(AccountSharedAccountDeletedRemotely());
          return;
        }

        emit(
          AccountSharingStatusChanged(sharedAccountId: sharedAccountId),
        );
      },
      onError: (error) {
        emit(AccountSharingError(error.toString()));
      },
    );
  }

  void _startWatchingSentInvitations() {
    _sentInvitationsSubscription?.cancel();

    _sentInvitationsSubscription =
        repository.watchSentInvitationsStatus().listen(
      (invitations) {
        final currentStatuses = <String, String>{};
        for (final inv in invitations) {
          currentStatuses[inv.id] = inv.status;
        }

        if (!_sentInvitationsInitialized) {
          _previousInvitationStatuses
            ..clear()
            ..addAll(currentStatuses);
          _sentInvitationsInitialized = true;
          return;
        }

        for (final entry in currentStatuses.entries) {
          final previousStatus = _previousInvitationStatuses[entry.key];
          final currentStatus = entry.value;

          if (previousStatus == 'pending' && currentStatus == 'accepted') {
            if (_isLocalAccepting) {
              _isLocalAccepting = false;
            } else {
              emit(AccountInvitationAcceptedRemotely());
            }
          }

          if (previousStatus == 'pending' && currentStatus == 'rejected') {
            if (_isLocalRejecting) {
              _isLocalRejecting = false;
            } else {
              emit(AccountInvitationRejectedRemotely());
            }
          }
        }

        _previousInvitationStatuses
          ..clear()
          ..addAll(currentStatuses);
      },
      onError: (error) {
        emit(AccountSharingError(error.toString()));
      },
    );
  }

  Future<void> sendInvitation({required String email}) async {
    emit(AccountSharingLoading());

    try {
      await repository.sendInvitation(email: email);

      emit(AccountInvitationSent());
    } catch (e) {
      emit(AccountSharingError(e.toString()));
    }
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    return repository.watchReceivedInvitations();
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    emit(AccountSharingLoading());

    try {
      if (accept) {
        _isLocalAccepting = true;
      } else {
        _isLocalRejecting = true;
      }

      await repository.respondToInvitation(
        invitationId: invitationId,
        accept: accept,
      );

      if (accept) {
        _sharedAccountId = await repository.getSharedAccountId();
        emit(AccountInvitationAccepted());
      } else {
        _sharedAccountId = null;
        emit(AccountInvitationRejected());
      }

      emit(AccountSharingStatusChanged(sharedAccountId: _sharedAccountId));
    } catch (e) {
      _isLocalAccepting = false;
      _isLocalRejecting = false;
      emit(AccountSharingError(e.toString()));
    }
  }

  Future<String?> getSharedAccountId() async {
    final id = await repository.getSharedAccountId();

    _sharedAccountId = id;

    return id;
  }

  Future<void> deleteSharedAccount() async {
    emit(AccountSharingLoading());

    try {
      _isLocalDeleting = true;

      await repository.deleteSharedAccount();

      _sharedAccountId = null;

      emit(AccountSharedAccountDeleted());

      emit(AccountSharingStatusChanged(sharedAccountId: null));
    } catch (e) {
      _isLocalDeleting = false;
      emit(AccountSharingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sharedAccountSubscription?.cancel();
    _sentInvitationsSubscription?.cancel();
    return super.close();
  }
}
