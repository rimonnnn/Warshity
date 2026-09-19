import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class AccountSharingCubit extends Cubit<AccountSharingState> {
  AccountSharingCubit(this.repository) : super(AccountSharingInitial());

  final AccountSharingRepository repository;

  StreamSubscription<List<Map<String, dynamic>>>? _sharedAccountsSubscription;

  StreamSubscription<Map<String, String>>? _sentInvitationsSubscription;

  List<Map<String, dynamic>> _connections = [];

  Map<String, String> _lastSentStatuses = {};

  bool _sharedWatcherInitialized = false;
  bool _sentWatcherInitialized = false;

  bool _localAccept = false;
  String? _localDeletedConnectionId;

  List<Map<String, dynamic>> get connections => List.unmodifiable(_connections);

  List<String> get connectionIds {
    return _connections
        .map((connection) => connection['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  int get connectionsCount => _connections.length;

  bool get isShared => _connections.isNotEmpty;

  String? get sharedAccountId {
    if (_connections.isEmpty) {
      return null;
    }

    return _connections.first['id']?.toString();
  }

  void startWatchingSharedAccounts() {
    _sharedAccountsSubscription?.cancel();
    _sentInvitationsSubscription?.cancel();

    _sharedWatcherInitialized = false;
    _sentWatcherInitialized = false;

    _connections = [];
    _lastSentStatuses = {};

    _sharedAccountsSubscription = repository.watchActiveSharedAccounts().listen(
      _handleSharedAccountsChange,
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

  void startWatchingSharedAccount() {
    startWatchingSharedAccounts();
  }

  void _handleSharedAccountsChange(List<Map<String, dynamic>> value) {
    final newConnections = List<Map<String, dynamic>>.from(value);

    final oldIds = _connections
        .map((connection) => connection['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final newIds = newConnections
        .map((connection) => connection['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (!_sharedWatcherInitialized) {
      _sharedWatcherInitialized = true;
      _connections = newConnections;

      if (!isClosed) {
        emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
      }

      return;
    }

    final addedIds = newIds.difference(oldIds);
    final removedIds = oldIds.difference(newIds);

    _connections = newConnections;

    if (addedIds.isNotEmpty) {
      if (_localAccept) {
        _localAccept = false;
      } else if (!isClosed) {
        emit(AccountInvitationAcceptedRemotely());
      }
    }

    if (removedIds.isNotEmpty) {
      if (_localDeletedConnectionId != null &&
          removedIds.contains(_localDeletedConnectionId)) {
        _localDeletedConnectionId = null;
      } else if (!isClosed) {
        emit(AccountSharedAccountDeletedRemotely());
      }
    }

    if (!isClosed) {
      emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
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

  Future<void> sendInvitation({required String email}) async {
    if (isClosed) {
      return;
    }

    emit(AccountSharingLoading());

    try {
      await repository.sendInvitation(email: email);

      if (!isClosed) {
        emit(AccountInvitationSent());
      }
    } catch (e) {
      if (!isClosed) {
        emit(AccountSharingError(e.toString()));
      }
    }
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    return repository.watchReceivedInvitations();
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    if (isClosed) {
      return;
    }

    emit(AccountSharingLoading());

    try {
      if (accept) {
        _localAccept = true;

        await repository.respondToInvitation(
          invitationId: invitationId,
          accept: true,
        );

        if (!isClosed) {
          emit(AccountInvitationAccepted());
        }
      } else {
        await repository.respondToInvitation(
          invitationId: invitationId,
          accept: false,
        );

        if (!isClosed) {
          emit(AccountInvitationRejected());
        }
      }
    } catch (e) {
      _localAccept = false;

      if (!isClosed) {
        emit(AccountSharingError(e.toString()));
      }
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSharedAccounts() async {
    final result = await repository.getActiveSharedAccounts();

    _connections = List<Map<String, dynamic>>.from(result);

    return connections;
  }

  Future<List<String>> getActiveConnectionIds() {
    return repository.getActiveConnectionIds();
  }

  Future<List<String>> getConnectedUserIds() {
    return repository.getConnectedUserIds();
  }

  Future<List<String>> getConnectionMembers(String connectionId) {
    return repository.getConnectionMembers(connectionId);
  }

  Future<void> deleteSharedAccount(String connectionId) async {
    if (isClosed) {
      return;
    }

    if (connectionId.trim().isEmpty) {
      return;
    }

    emit(AccountSharingLoading());

    try {
      _localDeletedConnectionId = connectionId;

      await repository.deleteSharedAccount(connectionId);

      _connections.removeWhere(
        (connection) => connection['id']?.toString() == connectionId,
      );

      if (!isClosed) {
        emit(AccountSharedAccountDeleted());

        emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
      }

      _localDeletedConnectionId = null;
    } catch (e) {
      _localDeletedConnectionId = null;

      if (!isClosed) {
        emit(AccountSharingError(e.toString()));
      }
    }
  }

  Future<String?> getSharedAccountId() async {
    if (_connections.isEmpty) {
      await getActiveSharedAccounts();
    }

    return sharedAccountId;
  }

  int get activeConnectionsCount {
    return _connections.length;
  }

  bool get hasReachedMaxConnections {
    return _connections.length >= 5;
  }

  @override
  Future<void> close() async {
    await _sharedAccountsSubscription?.cancel();
    await _sentInvitationsSubscription?.cancel();

    _sharedAccountsSubscription = null;
    _sentInvitationsSubscription = null;

    return super.close();
  }
}
