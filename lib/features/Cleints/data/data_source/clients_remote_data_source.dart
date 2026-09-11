import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

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

  Future<String?> _getSharedAccountId() async {
    return GetIt.I<AccountSharingRepository>().getSharedAccountId();
  }

  Stream<List<CustomerModel>> watchClients() {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((sharedAccountId) {
      Query<Map<String, dynamic>> query = firestore.collection('clients');

      if (sharedAccountId == null || sharedAccountId.isEmpty) {
        query = query.where('userId', isEqualTo: uid);
      } else {
        query = query.where(
          'sharedAccountId',
          isEqualTo: sharedAccountId,
        );
      }

      return query.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()))
            .toList(),
      );
    });
  }

  Stream<CustomerModel> watchClient(String clientId) async* {
    yield* firestore.collection('clients').doc(clientId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('client_not_found'.tr());
      }

      final data = doc.data()!;

      return CustomerModel.fromFirestore(doc.id, data);
    });
  }

  Future<void> addClient(CustomerModel client) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final data = client.toFirestore();

    data['userId'] = uid;

    if (sharedAccountId != null) {
      data['sharedAccountId'] = sharedAccountId;
    }

    await firestore.collection('clients').add(data);
  }

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      if (ownerUid == null || ownerUid.isEmpty) {
        throw Exception('client_not_found'.tr());
      }

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final docSharedId = data['sharedAccountId']?.toString();
        if (docSharedId != sharedAccountId) {
          throw Exception('client_not_found'.tr());
        }
      } else {
        if (ownerUid != uid) {
          throw Exception('client_not_found'.tr());
        }
      }

      final currentBalance = (data['balance'] as num?) ?? 0;

      if (amount <= 0) {
        throw Exception('invalid_debt_amount'.tr());
      }

      if (amount > currentBalance) {
        throw Exception('debt_payment_exceeds_balance'.tr());
      }

      final newBalance = currentBalance - amount;

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  Future<void> increaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      if (ownerUid == null || ownerUid.isEmpty) {
        throw Exception('client_not_found'.tr());
      }

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final docSharedId = data['sharedAccountId']?.toString();
        if (docSharedId != sharedAccountId) {
          throw Exception('client_not_found'.tr());
        }
      } else {
        if (ownerUid != uid) {
          throw Exception('client_not_found'.tr());
        }
      }

      final currentBalance = (data['balance'] as num?) ?? 0;

      if (amount <= 0) {
        return;
      }

      final newBalance = currentBalance + amount;

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  Future<void> removeClient(String clientId) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final invoicesRef = firestore.collection('invoices');

    final clientRef = firestore.collection('clients').doc(clientId);

    final clientSnapshot = await clientRef.get();

    if (!clientSnapshot.exists) {
      throw Exception('client_not_found'.tr());
    }

    final clientData = clientSnapshot.data();

    if (clientData == null) {
      throw Exception('client_not_found'.tr());
    }

    final clientOwnerUid = clientData['userId']?.toString();

    if (clientOwnerUid == null || clientOwnerUid.isEmpty) {
      throw Exception('client_not_found'.tr());
    }

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      final docSharedId = clientData['sharedAccountId']?.toString();
      if (docSharedId != sharedAccountId) {
        throw Exception('client_not_found'.tr());
      }
    } else {
      if (clientOwnerUid != uid) {
        throw Exception('client_not_found'.tr());
      }
    }

    while (true) {
      Query<Map<String, dynamic>> query = invoicesRef.where(
        'customerId',
        isEqualTo: clientId,
      );

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        query = query.where(
          'sharedAccountId',
          isEqualTo: sharedAccountId,
        );
      } else {
        query = query.where('userId', isEqualTo: uid);
      }

      final snapshot = await query.limit(400).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final Map<String, int> quantities = {};

      for (final invoiceDoc in snapshot.docs) {
        final data = invoiceDoc.data();

        final stockDeducted = data['stockDeducted'] == true;

        if (!stockDeducted) {
          continue;
        }

        final items = data['items'];

        if (items is List) {
          for (final item in items) {
            if (item is! Map) {
              continue;
            }

            final productId = item['productId']?.toString() ?? '';

            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

            if (productId.isEmpty || quantity <= 0) {
              continue;
            }

            quantities[productId] = (quantities[productId] ?? 0) + quantity;
          }
        }
      }

      final batch = firestore.batch();

      for (final invoiceDoc in snapshot.docs) {
        batch.delete(invoiceDoc.reference);
      }

      for (final entry in quantities.entries) {
        final productRef = firestore.collection('products').doc(entry.key);

        batch.update(productRef, {
          'quantity': FieldValue.increment(entry.value),
        });
      }

      await batch.commit();
    }

    await clientRef.delete();
  }
}
