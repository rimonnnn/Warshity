import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

import 'client_access_checker.dart';
import 'client_debt_service.dart';
import 'client_reconciler.dart';
import 'client_remover.dart';
import 'clients_watcher.dart';

class ClientsRemoteDataSource {
  final FirebaseFirestore firestore;

  ClientsRemoteDataSource(this.firestore);

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  AccountSharingRepository get _sharingRepository =>
      GetIt.I<AccountSharingRepository>();

  Future<List<String>> _getActiveConnectionIds() {
    return _sharingRepository.getActiveConnectionIds();
  }

  ClientDebtService get _debtService =>
      ClientDebtService(firestore, _getActiveConnectionIds);

  Future<bool> _hasAccessToClient(Map<String, dynamic> data) async {
    final uid = _currentUserId;

    if (data['userId']?.toString() == uid) {
      return true;
    }

    return ClientAccessChecker.hasAccess(
      data: data,
      uid: uid,
      activeConnectionIds: await _getActiveConnectionIds(),
      requireActiveConnections: true,
    );
  }

  Stream<List<CustomerModel>> watchClients() {
    return ClientsWatcher(firestore, _sharingRepository).watchClients(
      _currentUserId,
    );
  }

  Stream<CustomerModel> watchClient(String clientId) async* {
    yield* firestore.collection('clients').doc(clientId).snapshots().asyncMap((
      doc,
    ) async {
      if (!doc.exists || doc.data() == null) {
        throw Exception('client_not_found'.tr());
      }

      final data = doc.data()!;

      if (!await _hasAccessToClient(data)) {
        throw Exception('client_not_found'.tr());
      }

      return CustomerModel.fromFirestore(doc.id, data);
    });
  }

  Future<void> addClient(CustomerModel client) async {
    final uid = _currentUserId;
    final connectionIds = await _getActiveConnectionIds();
    final ref = firestore.collection('clients').doc();

    final data = client.toFirestore();

    data['userId'] = uid;
    data['userIds'] = [uid];
    data['sharedConnectionIds'] = connectionIds;
    data['sharedDataId'] = ref.id;

    data.remove('sharedAccountId');

    await ref.set(data);
  }

  Future<void> decreaseDebt({required String clientId, required num amount}) {
    return _debtService.decreaseDebt(
      uid: _currentUserId,
      clientId: clientId,
      amount: amount,
    );
  }

  Future<void> increaseDebt({required String clientId, required num amount}) {
    return _debtService.increaseDebt(
      uid: _currentUserId,
      clientId: clientId,
      amount: amount,
    );
  }

  Future<int> reconcileInvoiceOutstandingAmountsWithClientBalances() async {
    final uid = _currentUserId;
    final activeConnectionIds = await _getActiveConnectionIds();
    final clients = await watchClients().first;

    return ClientReconciler(firestore).reconcile(
      clients: clients,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    );
  }

  Future<void> removeClient(String clientId) {
    return ClientRemover(
      firestore,
      _getActiveConnectionIds,
    ).removeClient(uid: _currentUserId, clientId: clientId);
  }
}
