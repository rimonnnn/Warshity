import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class AccountSharingCubit extends Cubit<AccountSharingState> {
  AccountSharingCubit(this.repository) : super(AccountSharingInitial());

  final AccountSharingRepository repository;

  StreamSubscription<String?>? _sharedAccountSubscription;
  StreamSubscription<Map<String, String>>? _sentInvitationsSubscription;

  String? _sharedAccountId;
  String? _lastSharedAccountId;

  bool _sharedWatcherInitialized = false;
  bool _sentWatcherInitialized = false;

  bool _localAccept = false;
  bool _localDelete = false;

  Map<String, String> _lastSentStatuses = {};

  String? get sharedAccountId => _sharedAccountId;

  bool get isShared => _sharedAccountId != null && _sharedAccountId!.isNotEmpty;

  void startWatchingSharedAccount() {
    _sharedAccountSubscription?.cancel();
    _sentInvitationsSubscription?.cancel();

    _sharedWatcherInitialized = false;
    _sentWatcherInitialized = false;
    _lastSharedAccountId = null;
    _lastSentStatuses = {};

    _sharedAccountSubscription = repository.watchSharedAccountId().listen(
      _handleSharedAccountChange,
      onError: (error) {
        if (!isClosed) {
          emit(AccountSharingError(error.toString()));
        }
      },
    );

    _sentInvitationsSubscription = repository
        .watchSentInvitationStatuses()
        .listen(
          _handleSentInvitationStatuses,
          onError: (error) {
            if (!isClosed) {
              emit(AccountSharingError(error.toString()));
            }
          },
        );
  }

  void _handleSharedAccountChange(String? value) {
    final newId = _normalize(value);

    if (!_sharedWatcherInitialized) {
      _sharedWatcherInitialized = true;
      _lastSharedAccountId = newId;
      _sharedAccountId = newId;

      if (!isClosed) {
        emit(AccountSharingStatusChanged(sharedAccountId: newId));
      }

      return;
    }

    final oldId = _lastSharedAccountId;

    final changedToShared = oldId == null && newId != null;

    final changedToPrivate = oldId != null && newId == null;

    _lastSharedAccountId = newId;
    _sharedAccountId = newId;

    if (changedToShared) {
      if (_localAccept) {
        _localAccept = false;
      } else {
        if (!isClosed) {
          emit(AccountInvitationAcceptedRemotely());
        }
      }
    }

    if (changedToPrivate) {
      if (_localDelete) {
        _localDelete = false;
      } else {
        if (!isClosed) {
          emit(AccountSharedAccountDeletedRemotely());
        }
      }
    }

    if (!isClosed) {
      emit(AccountSharingStatusChanged(sharedAccountId: newId));
    }
  }

  void _handleSentInvitationStatuses(Map<String, String> statuses) {
    if (!_sentWatcherInitialized) {
      _sentWatcherInitialized = true;
      _lastSentStatuses = Map<String, String>.from(statuses);
      return;
    }

    for (final entry in statuses.entries) {
      final invitationId = entry.key;
      final newStatus = entry.value;

      final oldStatus = _lastSentStatuses[invitationId];

      if (oldStatus == 'pending' && newStatus == 'rejected') {
        if (!isClosed) {
          emit(AccountInvitationRejectedRemotely());
        }
      }
    }

    _lastSentStatuses = Map<String, String>.from(statuses);
  }

  String? _normalize(String? value) {
    if (value == null) {
      return null;
    }

    final result = value.trim();

    return result.isEmpty ? null : result;
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
        _localAccept = true;

        await repository.respondToInvitation(
          invitationId: invitationId,
          accept: true,
        );

        final id = await repository.getSharedAccountId();

        _sharedAccountId = _normalize(id);
        _lastSharedAccountId = _sharedAccountId;

        emit(AccountInvitationAccepted());

        emit(AccountSharingStatusChanged(sharedAccountId: _sharedAccountId));
      } else {
        await repository.respondToInvitation(
          invitationId: invitationId,
          accept: false,
        );

        emit(AccountInvitationRejected());
      }
    } catch (e) {
      _localAccept = false;
      emit(AccountSharingError(e.toString()));
    }
  }

  Future<String?> getSharedAccountId() async {
    final id = await repository.getSharedAccountId();

    _sharedAccountId = _normalize(id);
    _lastSharedAccountId = _sharedAccountId;

    return _sharedAccountId;
  }

  Future<void> deleteSharedAccount() async {
    emit(AccountSharingLoading());

    try {
      _localDelete = true;

      await repository.deleteSharedAccount();

      _sharedAccountId = null;
      _lastSharedAccountId = null;

      emit(AccountSharedAccountDeleted());

      emit(AccountSharingStatusChanged(sharedAccountId: null));
    } catch (e) {
      _localDelete = false;
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
