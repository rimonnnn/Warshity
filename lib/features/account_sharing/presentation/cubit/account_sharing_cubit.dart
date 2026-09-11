import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class AccountSharingCubit extends Cubit<AccountSharingState> {
  AccountSharingCubit(this.repository) : super(AccountSharingInitial());

  final AccountSharingRepository repository;

  StreamSubscription<String?>? _sharedAccountSubscription;

  String? _sharedAccountId;

  String? get sharedAccountId => _sharedAccountId;

  bool get isShared => _sharedAccountId != null;

  void startWatchingSharedAccount() {
  _sharedAccountSubscription?.cancel();

  _sharedAccountSubscription =
      repository.watchSharedAccountId().listen(
    (sharedAccountId) {
      print(
        'CUBIT SHARED ACCOUNT => $sharedAccountId',
      );

      _sharedAccountId = sharedAccountId;

      emit(
        AccountSharingStatusChanged(
          sharedAccountId: sharedAccountId,
        ),
      );
    },
    onError: (error) {
      emit(
        AccountSharingError(
          error.toString(),
        ),
      );
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
      await repository.respondToInvitation(
        invitationId: invitationId,
        accept: accept,
      );

      if (accept) {
        _sharedAccountId = await repository.getSharedAccountId();
      } else {
        _sharedAccountId = null;
      }

      emit(AccountInvitationResponded());

      emit(AccountSharingStatusChanged(sharedAccountId: _sharedAccountId));
    } catch (e) {
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
      await repository.deleteSharedAccount();

      _sharedAccountId = null;

      emit(AccountSharedAccountDeleted());

      emit(AccountSharingStatusChanged(sharedAccountId: null));
    } catch (e) {
      emit(AccountSharingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sharedAccountSubscription?.cancel();
    return super.close();
  }
}
