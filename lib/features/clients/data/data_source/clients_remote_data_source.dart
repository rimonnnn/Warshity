import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/clients/data/model/customer_model.dart';
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

  AccountSharingRepository get _sharingRepository =>
      GetIt.I<AccountSharingRepository>();

  Future<List<String>> _getActiveConnectionIds() async {
    return _sharingRepository.getActiveConnectionIds();
  }

  Future<bool> _hasAccessToClient(Map<String, dynamic> data) async {
    final uid = _currentUserId;

    final ownerUid = data['userId']?.toString();

    if (ownerUid == uid) {
      return true;
    }

    final connectionIds = await _getActiveConnectionIds();

    if (connectionIds.isEmpty) {
      return false;
    }

    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isNotEmpty) {
      return sharedConnectionIds.any(connectionIds.contains);
    }

    final legacyUserIds = _normalizeIds(data['userIds']);

    return legacyUserIds.contains(uid);
  }

  List<String> _normalizeIds(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Stream<List<CustomerModel>> watchClients() {
    final uid = _currentUserId;

    return _sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('clients')
            .where('userId', isEqualTo: uid)
            .snapshots(),
      );

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) {
          continue;
        }

        streams.add(
          firestore
              .collection('clients')
              .where('sharedConnectionIds', arrayContains: connectionId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map(_mapClientSnapshot);
      }

      return Stream.multi((controller) {
        final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          final clients = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()!))
              .toList();

          controller.add(clients);
        }

        for (final stream in streams) {
          final subscription = stream.listen((snapshot) {
            for (final change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.removed) {
                documents.remove(change.doc.id);
              } else {
                documents[change.doc.id] = change.doc;
              }
            }

            emit();
          }, onError: controller.addError);

          subscriptions.add(subscription);
        }

        controller.onCancel = () async {
          for (final subscription in subscriptions) {
            await subscription.cancel();
          }
        };
      });
    });
  }

  List<CustomerModel> _mapClientSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Stream<CustomerModel> watchClient(String clientId) async* {
    yield* firestore.collection('clients').doc(clientId).snapshots().asyncMap((
      doc,
    ) async {
      if (!doc.exists || doc.data() == null) {
        throw Exception('client_not_found'.tr());
      }

      final data = doc.data()!;

      final hasAccess = await _hasAccessToClient(data);

      if (!hasAccess) {
        throw Exception('client_not_found'.tr());
      }

      return CustomerModel.fromFirestore(doc.id, data);
    });
  }

  Future<void> addClient(CustomerModel client) async {
    final uid = _currentUserId;

    final connectionIds = await _getActiveConnectionIds();

    final data = client.toFirestore();

    data['userId'] = uid;

    data['userIds'] = [uid];

    data['sharedConnectionIds'] = connectionIds;

    final ref = firestore.collection('clients').doc();

    data['sharedDataId'] = ref.id;

    data.remove('sharedAccountId');

    await ref.set(data);
  }

  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final uid = _currentUserId;
    final activeConnectionIds = await _getActiveConnectionIds();
    final clientRef = firestore.collection('clients').doc(clientId);

    final invoicesCollection = firestore.collection('invoices');
    final invoiceQueries = <Future<QuerySnapshot<Map<String, dynamic>>>>[
      invoicesCollection
          .where('userId', isEqualTo: uid)
          .where('customerId', isEqualTo: clientId)
          .get(),

      invoicesCollection
          .where('userIds', arrayContains: uid)
          .where('customerId', isEqualTo: clientId)
          .get(),
    ];
    for (final connectionId in activeConnectionIds) {
      if (connectionId.isEmpty) continue;
      invoiceQueries.add(
        invoicesCollection
            .where('sharedConnectionIds', arrayContains: connectionId)
            .where('customerId', isEqualTo: clientId)
            .get(),
      );
    }

    final invoiceRefsById = <String, DocumentReference<Map<String, dynamic>>>{};
    for (final queryFuture in invoiceQueries) {
      final snapshot = await queryFuture;
      for (final doc in snapshot.docs) {
        invoiceRefsById[doc.id] = doc.reference;
      }
    }
    final invoiceRefs = invoiceRefsById.values.toList();

    await firestore.runTransaction((transaction) async {
      final clientSnapshot = await transaction.get(clientRef);

      if (!clientSnapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final clientData = clientSnapshot.data() ?? {};
      final ownerUid = clientData['userId']?.toString();

      if (ownerUid != uid) {
        final sharedConnectionIds = _normalizeIds(
          clientData['sharedConnectionIds'],
        );
        final legacyUserIds = _normalizeIds(clientData['userIds']);
        final hasSharedAccess =
            sharedConnectionIds.any(activeConnectionIds.contains) ||
            legacyUserIds.contains(uid);

        if (!hasSharedAccess) {
          throw Exception('client_not_found'.tr());
        }
      }

      final currentBalance = (clientData['balance'] as num?) ?? 0;

      if (amount <= 0) {
        throw Exception('invalid_debt_amount'.tr());
      }

      if (amount > currentBalance) {
        throw Exception('debt_payment_exceeds_balance'.tr());
      }

      final invoiceSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final invoiceRef in invoiceRefs) {
        final invoiceSnapshot = await transaction.get(invoiceRef);
        if (invoiceSnapshot.exists && invoiceSnapshot.data() != null) {
          invoiceSnapshots.add(invoiceSnapshot);
        }
      }

      invoiceSnapshots.sort((a, b) {
        final dateA = a.data()?['createdAt']?.toString() ?? '';
        final dateB = b.data()?['createdAt']?.toString() ?? '';
        return dateA.compareTo(dateB);
      });

      var amountLeftToAllocate = amount.toDouble();
      final invoiceUpdates =
          <
            MapEntry<
              DocumentReference<Map<String, dynamic>>,
              Map<String, dynamic>
            >
          >[];

      for (final invoiceSnapshot in invoiceSnapshots) {
        if (amountLeftToAllocate <= 0) break;

        final invoiceData = invoiceSnapshot.data()!;
        final invoiceOwnerUid = invoiceData['userId']?.toString();
        final sharedInvoiceIds = _normalizeIds(
          invoiceData['sharedConnectionIds'],
        );
        final legacyInvoiceUserIds = _normalizeIds(invoiceData['userIds']);
        final canUpdateInvoice =
            invoiceOwnerUid == uid ||
            sharedInvoiceIds.any(activeConnectionIds.contains) ||
            legacyInvoiceUserIds.contains(uid);

        if (!canUpdateInvoice) continue;

        final remainingAmount =
            (invoiceData['remainingAmount'] as num?)?.toDouble() ?? 0.0;
        if (remainingAmount <= 0) continue;

        final paidAmount =
            (invoiceData['paidAmount'] as num?)?.toDouble() ?? 0.0;
        final totalAmount = (invoiceData['total'] as num?)?.toDouble() ?? 0.0;
        final appliedAmount = amountLeftToAllocate < remainingAmount
            ? amountLeftToAllocate
            : remainingAmount;
        final nextRemainingAmount = (remainingAmount - appliedAmount)
            .clamp(0.0, double.infinity)
            .toDouble();
        final nextPaidAmount = totalAmount > 0
            ? (totalAmount - nextRemainingAmount)
                  .clamp(0.0, totalAmount)
                  .toDouble()
            : paidAmount + appliedAmount;

        invoiceUpdates.add(
          MapEntry(invoiceSnapshot.reference, <String, dynamic>{
            'paidAmount': nextPaidAmount,
            'remainingAmount': nextRemainingAmount,
          }),
        );
        amountLeftToAllocate -= appliedAmount;
      }

      final newBalance = currentBalance - amount;
      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });

      for (final update in invoiceUpdates) {
        transaction.update(update.key, update.value);
      }
    });
  }

  Future<int> reconcileInvoiceOutstandingAmountsWithClientBalances() async {
    final uid = _currentUserId;
    final activeConnectionIds = await _getActiveConnectionIds();
    final clientsSnapshot = await firestore
        .collection('clients')
        .where('userId', isEqualTo: uid)
        .get();

    var updatedRecords = 0;
    var batchWriteCount = 0;
    var batch = firestore.batch();

    Future<void> commitIfNeeded({bool force = false}) async {
      if (batchWriteCount == 0 || (!force && batchWriteCount < 450)) {
        return;
      }
      await batch.commit();
      batch = firestore.batch();
      batchWriteCount = 0;
    }

    for (final clientDocument in clientsSnapshot.docs) {
      final clientData = clientDocument.data();
      final clientBalance = ((clientData['balance'] as num?) ?? 0).toDouble();

      final invoicesCollection = firestore.collection('invoices');
      final invoiceQueryFutures = <Future<QuerySnapshot<Map<String, dynamic>>>>[
        invoicesCollection
            .where('userId', isEqualTo: uid)
            .where('customerId', isEqualTo: clientDocument.id)
            .get(),
        invoicesCollection
            .where('userIds', arrayContains: uid)
            .where('customerId', isEqualTo: clientDocument.id)
            .get(),
      ];
      for (final connectionId in activeConnectionIds) {
        if (connectionId.isEmpty) continue;
        invoiceQueryFutures.add(
          invoicesCollection
              .where('sharedConnectionIds', arrayContains: connectionId)
              .where('customerId', isEqualTo: clientDocument.id)
              .get(),
        );
      }
      final invoiceSnapshots = await Future.wait(invoiceQueryFutures);
      final invoicesById =
          <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final invoiceSnapshot in invoiceSnapshots) {
        for (final invoice in invoiceSnapshot.docs) {
          invoicesById[invoice.id] = invoice;
        }
      }
      final invoices = invoicesById.values.toList()
        ..sort((a, b) {
          final dateA = a.data()['createdAt']?.toString() ?? '';
          final dateB = b.data()['createdAt']?.toString() ?? '';
          return dateA.compareTo(dateB);
        });

      final calculatedOrderCount = invoices.length;
      final calculatedTotalPurchases = invoices.fold<double>(
        0,
        (sum, invoice) =>
            sum + (((invoice.data()['total'] as num?) ?? 0).toDouble()),
      );
      final storedOrderCount = ((clientData['orderCount'] as num?) ?? 0)
          .toInt();
      final storedTotalPurchases = ((clientData['totalPurchases'] as num?) ?? 0)
          .toDouble();

      if (storedOrderCount != calculatedOrderCount ||
          (storedTotalPurchases - calculatedTotalPurchases).abs() > 0.009) {
        batch.update(clientDocument.reference, {
          'orderCount': calculatedOrderCount,
          'totalPurchases': calculatedTotalPurchases,
        });
        batchWriteCount++;
        updatedRecords++;
        await commitIfNeeded();
      }

      final outstandingTotal = invoices.fold<double>(
        0,
        (sum, invoice) =>
            sum +
            (((invoice.data()['remainingAmount'] as num?) ?? 0)
                .toDouble()
                .clamp(0.0, double.infinity)
                .toDouble()),
      );

      var amountToApply = outstandingTotal - clientBalance;
      if (amountToApply <= 0) continue;

      for (final invoice in invoices) {
        if (amountToApply <= 0) break;

        final data = invoice.data();
        final remaining = ((data['remainingAmount'] as num?) ?? 0).toDouble();
        if (remaining <= 0) continue;

        final appliedAmount = amountToApply < remaining
            ? amountToApply
            : remaining;
        final paidAmount = ((data['paidAmount'] as num?) ?? 0).toDouble();
        final totalAmount = ((data['total'] as num?) ?? 0).toDouble();
        final nextRemaining = (remaining - appliedAmount)
            .clamp(0.0, double.infinity)
            .toDouble();
        final nextPaidAmount = totalAmount > 0
            ? (totalAmount - nextRemaining).clamp(0.0, totalAmount).toDouble()
            : paidAmount + appliedAmount;

        batch.update(invoice.reference, {
          'paidAmount': nextPaidAmount,
          'remainingAmount': nextRemaining,
        });
        batchWriteCount++;
        updatedRecords++;
        amountToApply -= appliedAmount;
        await commitIfNeeded();
      }
    }

    await commitIfNeeded(force: true);
    return updatedRecords;
  }

  Future<void> increaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final uid = _currentUserId;

    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(clientRef);

      if (!snapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final ownerUid = data['userId']?.toString();

      if (ownerUid != uid) {
        final connectionIds = await _getActiveConnectionIds();

        final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

        final hasAccess = sharedConnectionIds.any(connectionIds.contains);

        if (!hasAccess) {
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

    final hasClientAccess = await _hasAccessToClient(clientData);

    if (!hasClientAccess) {
      throw Exception('client_not_found'.tr());
    }

    final activeConnectionIds = await _getActiveConnectionIds();

    final snapshot = await invoicesRef
        .where('customerId', isEqualTo: clientId)
        .get();

    const batchSize = 400;

    for (var start = 0; start < snapshot.docs.length; start += batchSize) {
      final end = (start + batchSize < snapshot.docs.length)
          ? start + batchSize
          : snapshot.docs.length;

      final batch = firestore.batch();

      final quantities = <String, int>{};

      for (var index = start; index < end; index++) {
        final invoiceDoc = snapshot.docs[index];

        final data = invoiceDoc.data();

        final ownerUid = data['userId']?.toString();

        var hasAccess = ownerUid == uid;

        if (!hasAccess) {
          final sharedConnectionIds = _normalizeIds(
            data['sharedConnectionIds'],
          );

          hasAccess = sharedConnectionIds.any(activeConnectionIds.contains);

          if (!hasAccess && sharedConnectionIds.isEmpty) {
            final legacyUserIds = _normalizeIds(data['userIds']);

            hasAccess = legacyUserIds.contains(uid);
          }
        }

        if (!hasAccess) {
          continue;
        }

        if (data['stockDeducted'] != true) {
          batch.delete(invoiceDoc.reference);
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

        batch.delete(invoiceDoc.reference);
      }

      for (final entry in quantities.entries) {
        batch.update(firestore.collection('products').doc(entry.key), {
          'quantity': FieldValue.increment(entry.value),
        });
      }

      await batch.commit();
    }

    await clientRef.delete();
  }
}
