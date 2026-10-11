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
  StreamSubscription<List<ShareInvitationModel>>?
  _receivedInvitationsSubscription;

  List<Map<String, dynamic>> _connections = [];

  Set<String> _lastWatchedConnectionIds = {};

  final Set<String> _locallyDeletedConnectionIds = {};

  Map<String, String> _lastSentStatuses = {};
  Set<String> _lastReceivedInvitationIds = {};

  bool _sharedWatcherInitialized = false;
  bool _sentWatcherInitialized = false;
  bool _receivedInvitationsWatcherInitialized = false;

  List<Map<String, dynamic>> get connections => List.unmodifiable(_connections);

  List<String> get connectionIds => _connections
      .map((connection) => connection['id']?.toString() ?? '')
      .where((id) => id.isNotEmpty)
      .toList();

  int get connectionsCount => _connections.length;

  bool get isShared => _connections.isNotEmpty;

  String? get sharedAccountId {
    if (_connections.isEmpty) return null;
    return _connections.first['id']?.toString();
  }

  void startWatchingSharedAccounts() {
    if (_sharedAccountsSubscription != null &&
        _sentInvitationsSubscription != null &&
        _receivedInvitationsSubscription != null) {
      return;
    }

    _sharedAccountsSubscription?.cancel();
    _sentInvitationsSubscription?.cancel();
    _receivedInvitationsSubscription?.cancel();

    _sharedWatcherInitialized = false;
    _sentWatcherInitialized = false;
    _receivedInvitationsWatcherInitialized = false;
    _connections = [];
    _lastWatchedConnectionIds = {};
    _lastSentStatuses = {};
    _lastReceivedInvitationIds = {};

    _sharedAccountsSubscription = repository.watchActiveSharedAccounts().listen(
      _handleSharedAccountsChange,
      onError: (error) {
        if (!isClosed) emit(AccountSharingError(error.toString()));
      },
    );

    _sentInvitationsSubscription = repository
        .watchSentInvitationStatuses()
        .listen(
          _handleSentInvitationStatuses,
          onError: (error) {
            if (!isClosed) emit(AccountSharingError(error.toString()));
          },
        );

    _receivedInvitationsSubscription = repository
        .watchReceivedInvitations()
        .listen(
          _handleReceivedInvitationsChange,
          onError: (error) {
            if (!isClosed) emit(AccountSharingError(error.toString()));
          },
        );
  }

  void startWatchingSharedAccount() => startWatchingSharedAccounts();

  void _handleSharedAccountsChange(List<Map<String, dynamic>> value) {
    final newConnections = List<Map<String, dynamic>>.from(value);
    final newIds = newConnections
        .map((connection) => connection['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (!_sharedWatcherInitialized) {
      _sharedWatcherInitialized = true;
      _lastWatchedConnectionIds = newIds;
      _connections = newConnections;
      if (!isClosed) {
        emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
      }
      return;
    }

    final removedIds = _lastWatchedConnectionIds.difference(newIds);
    _lastWatchedConnectionIds = newIds;
    _connections = newConnections;

    if (removedIds.isNotEmpty) {
      var hasRemoteDeletion = false;

      for (final removedId in removedIds) {
        if (_locallyDeletedConnectionIds.remove(removedId)) {
          continue;
        }
        hasRemoteDeletion = true;
      }

      if (hasRemoteDeletion && !isClosed) {
        emit(AccountSharedAccountDeletedRemotely());
      }
    }

    final loadingState = state is AccountSharingLoading
        ? state as AccountSharingLoading
        : null;
    final keepActionLoading =
        loadingState?.action == 'accept' ||
        loadingState?.action == 'reject' ||
        loadingState?.action == 'delete';

    if (!isClosed && !keepActionLoading) {
      emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
    }
  }

  void _handleReceivedInvitationsChange(
    List<ShareInvitationModel> invitations,
  ) {
    final newIds = invitations
        .map((invitation) => invitation.id)
        .where((id) => id.isNotEmpty)
        .toSet();

    if (!_receivedInvitationsWatcherInitialized) {
      _receivedInvitationsWatcherInitialized = true;
      _lastReceivedInvitationIds = newIds;
      return;
    }

    final addedIds = newIds.difference(_lastReceivedInvitationIds);
    _lastReceivedInvitationIds = newIds;

    if (addedIds.isNotEmpty && !isClosed) {
      emit(AccountInvitationReceivedRemotely());
    }
  }

  void _handleSentInvitationStatuses(Map<String, String> statuses) {
    if (!_sentWatcherInitialized) {
      _sentWatcherInitialized = true;
      _lastSentStatuses = Map<String, String>.from(statuses);
      return;
    }

    var acceptedRemotely = false;
    var rejectedRemotely = false;

    for (final entry in statuses.entries) {
      final oldStatus = _lastSentStatuses[entry.key];
      final newStatus = entry.value;

      if (oldStatus == 'pending' && newStatus == 'accepted') {
        acceptedRemotely = true;
      } else if (oldStatus == 'pending' && newStatus == 'rejected') {
        rejectedRemotely = true;
      }
    }

    _lastSentStatuses = Map<String, String>.from(statuses);

    if (!isClosed && acceptedRemotely) {
      emit(AccountInvitationAcceptedRemotely());
    } else if (!isClosed && rejectedRemotely) {
      emit(AccountInvitationRejectedRemotely());
    }
  }

  Future<void> sendInvitation({required String email}) async {
    if (isClosed) return;

    emit(AccountSharingLoading(action: 'send'));
    try {
      await repository.sendInvitation(email: email);
      if (!isClosed) emit(AccountInvitationSent());
    } catch (e) {
      if (!isClosed) emit(AccountSharingError(e.toString()));
    }
  }

  Stream<List<ShareInvitationModel>> watchReceivedInvitations() {
    return repository.watchReceivedInvitations();
  }

  Future<void> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    if (isClosed) return;

    emit(
      AccountSharingLoading(
        action: accept ? 'accept' : 'reject',
        itemId: invitationId,
      ),
    );

    try {
      await repository.respondToInvitation(
        invitationId: invitationId,
        accept: accept,
      );

      if (isClosed) return;
      if (accept) {
        emit(AccountInvitationAccepted());
      } else {
        emit(AccountInvitationRejected());
      }
    } catch (e) {
      if (!isClosed) emit(AccountSharingError(e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSharedAccounts() async {
    final result = await repository.getActiveSharedAccounts();
    _connections = List<Map<String, dynamic>>.from(result);
    return connections;
  }

  Future<List<String>> getActiveConnectionIds() =>
      repository.getActiveConnectionIds();

  Future<List<String>> getConnectedUserIds() =>
      repository.getConnectedUserIds();

  Future<List<String>> getConnectionMembers(String connectionId) =>
      repository.getConnectionMembers(connectionId);

  Future<void> deleteSharedAccount(String connectionId) async {
    if (isClosed || connectionId.trim().isEmpty) return;

    emit(AccountSharingLoading(action: 'delete', itemId: connectionId));

    try {
      _locallyDeletedConnectionIds.add(connectionId);
      await repository.deleteSharedAccount(connectionId);
      _connections.removeWhere(
        (connection) => connection['id']?.toString() == connectionId,
      );

      if (!isClosed) {
        emit(AccountSharedAccountDeleted());
        emit(AccountSharingStatusChanged(sharedAccountId: sharedAccountId));
      }
    } catch (e) {
      _locallyDeletedConnectionIds.remove(connectionId);
      if (!isClosed) emit(AccountSharingError(e.toString()));
    }
  }

  Future<String?> getSharedAccountId() async {
    if (_connections.isEmpty) await getActiveSharedAccounts();
    return sharedAccountId;
  }

  int get activeConnectionsCount => _connections.length;

  bool get hasReachedMaxConnections => _connections.length >= 5;

  Future<void> stopWatchingSharedAccounts() async {
    await _sharedAccountsSubscription?.cancel();
    await _sentInvitationsSubscription?.cancel();
    await _receivedInvitationsSubscription?.cancel();

    _sharedAccountsSubscription = null;
    _sentInvitationsSubscription = null;
    _receivedInvitationsSubscription = null;

    _sharedWatcherInitialized = false;
    _sentWatcherInitialized = false;
    _receivedInvitationsWatcherInitialized = false;
    _connections = [];
    _lastWatchedConnectionIds = {};
    _lastSentStatuses = {};
    _lastReceivedInvitationIds = {};
    _locallyDeletedConnectionIds.clear();
  }

  @override
  Future<void> close() async {
    await _sharedAccountsSubscription?.cancel();
    await _sentInvitationsSubscription?.cancel();
    await _receivedInvitationsSubscription?.cancel();

    _sharedAccountsSubscription = null;
    _sentInvitationsSubscription = null;
    _receivedInvitationsSubscription = null;

    return super.close();
  }
}
