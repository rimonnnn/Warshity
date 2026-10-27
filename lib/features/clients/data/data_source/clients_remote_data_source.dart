import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/core/errors/app_failure.dart';
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      // Deliver the problem as a stream error instead of throwing during
      // widget build: cubits map it to a friendly error state.
      return Stream.error(const UnauthenticatedException());
    }

    return _sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[
        firestore
            .collection('clients')
            .where('userId', isEqualTo: uid)
            .snapshots(),
      ];

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) continue;
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
        final documentsByQuery =
            List<Map<String, DocumentSnapshot<Map<String, dynamic>>>>.generate(
          streams.length,
          (_) => <String, DocumentSnapshot<Map<String, dynamic>>>{},
        );
        final initialSnapshotsReceived = List<bool>.filled(streams.length, false);
        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          if (initialSnapshotsReceived.any((received) => !received)) return;

          final documents =
              <String, DocumentSnapshot<Map<String, dynamic>>>{};
          for (final queryDocuments in documentsByQuery) {
            documents.addAll(queryDocuments);
          }

          final clients = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => CustomerModel.fromFirestore(doc.id, doc.data()!))
              .toList();

          controller.add(clients);
        }

        for (var streamIndex = 0; streamIndex < streams.length; streamIndex++) {
          final subscription = streams[streamIndex].listen((snapshot) {
            final queryDocuments = documentsByQuery[streamIndex];
            queryDocuments.clear();
            for (final document in snapshot.docs) {
              queryDocuments[document.id] = document;
            }

            initialSnapshotsReceived[streamIndex] = true;
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

  /// Records a debt payment against the customer's outstanding invoices first,
  /// oldest invoice first, then updates the customer balance in the same
  /// transaction. This keeps paidAmount + remainingAmount aligned with the
  /// amount actually paid instead of only changing clients.balance.
  Future<void> decreaseDebt({
    required String clientId,
    required num amount,
  }) async {
    final uid = _currentUserId;
    if (amount <= 0) {
      throw Exception('invalid_debt_amount'.tr());
    }

    final activeConnectionIds = await _getActiveConnectionIds();
    final invoiceRefs = await _invoiceReferencesForClient(
      clientId,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
    );
    final clientRef = firestore.collection('clients').doc(clientId);

    await firestore.runTransaction((transaction) async {
      final clientSnapshot = await transaction.get(clientRef);

      if (!clientSnapshot.exists || clientSnapshot.data() == null) {
        throw Exception('client_not_found'.tr());
      }

      final clientData = clientSnapshot.data()!;
      if (!_canAccessRecord(
        data: clientData,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      )) {
        throw Exception('client_not_found'.tr());
      }

      final currentBalance =
          (clientData['balance'] as num?)?.toDouble() ?? 0.0;
      final paymentAmount = amount.toDouble();

      if (paymentAmount > currentBalance) {
        throw Exception('debt_payment_exceeds_balance'.tr());
      }

      // Read every candidate invoice before writing anything: Firestore
      // transactions require reads to happen before writes.
      final invoiceSnapshots =
          <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final invoiceRef in invoiceRefs) {
        final invoiceSnapshot = await transaction.get(invoiceRef);
        final invoiceData = invoiceSnapshot.data();
        if (!invoiceSnapshot.exists || invoiceData == null) continue;
        if (invoiceData['customerId']?.toString() != clientId) continue;
        if (!_canAccessRecord(
          data: invoiceData,
          uid: uid,
          activeConnectionIds: activeConnectionIds,
        )) {
          continue;
        }
        invoiceSnapshots.add(invoiceSnapshot);
      }

      invoiceSnapshots.sort((a, b) {
        return _invoiceDate(a.data()!).compareTo(_invoiceDate(b.data()!));
      });

      var unallocatedPayment = paymentAmount;
      for (final invoiceSnapshot in invoiceSnapshots) {
        final data = invoiceSnapshot.data()!;
        final total = _doubleValue(data['total']);
        if (total <= 0) continue;

        final paidAmount = _normalizedPaidAmount(data, total);
        final outstanding = (total - paidAmount).clamp(0.0, total).toDouble();

        var appliedAmount = 0.0;
        if (unallocatedPayment > 0.005 && outstanding > 0.005) {
          appliedAmount = unallocatedPayment < outstanding
              ? unallocatedPayment
              : outstanding;
          unallocatedPayment -= appliedAmount;
        }

        final newPaidAmount = (paidAmount + appliedAmount)
            .clamp(0.0, total)
            .toDouble();
        final newRemainingAmount =
            (total - newPaidAmount).clamp(0.0, total).toDouble();

        final storedPaid = data['paidAmount'];
        final storedRemaining = data['remainingAmount'];
        final paidNeedsUpdate = storedPaid is! num ||
            (storedPaid.toDouble() - newPaidAmount).abs() > 0.005;
        final remainingNeedsUpdate = storedRemaining is! num ||
            (storedRemaining.toDouble() - newRemainingAmount).abs() > 0.005;

        // Keep even untouched invoices internally consistent. Older records
        // sometimes had total/paidAmount correct but remainingAmount stale.
        if (appliedAmount > 0.005 ||
            paidNeedsUpdate ||
            remainingNeedsUpdate) {
          transaction.update(invoiceSnapshot.reference, {
            'paidAmount': newPaidAmount,
            'remainingAmount': newRemainingAmount,
          });
        }
      }

      final newBalance = (currentBalance - paymentAmount)
          .clamp(0.0, double.infinity)
          .toDouble();

      transaction.update(clientRef, {
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      });
    });
  }

  /// Repairs older data where payments were subtracted from the customer
  /// balance but never distributed to invoice paidAmount/remainingAmount.
  ///
  /// Only the excess invoice outstanding balance over the current customer
  /// balance is treated as an already-recorded payment. If outstanding
  /// invoices are lower than the customer balance, this method leaves the
  /// extra balance untouched because it may be a manually added debt.
  Future<int> reconcileInvoiceOutstandingAmountsWithClientBalances() async {
    final uid = _currentUserId;
    final activeConnectionIds = await _getActiveConnectionIds();
    final clients = await watchClients().first;
    var updatedRecordCount = 0;

    for (final client in clients) {
      final clientId = client.id;
      if (clientId == null || clientId.isEmpty) continue;

      final invoiceRefs = await _invoiceReferencesForClient(
        clientId,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
      );
      final clientRef = firestore.collection('clients').doc(clientId);
      final updatedForClient = await firestore.runTransaction<int>((
        transaction,
      ) async {
        final clientSnapshot = await transaction.get(clientRef);
        if (!clientSnapshot.exists || clientSnapshot.data() == null) return 0;

        final clientData = clientSnapshot.data()!;
        if (!_canAccessRecord(
          data: clientData,
          uid: uid,
          activeConnectionIds: activeConnectionIds,
        )) {
          return 0;
        }

        final invoiceSnapshots =
            <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final invoiceRef in invoiceRefs) {
          final invoiceSnapshot = await transaction.get(invoiceRef);
          final invoiceData = invoiceSnapshot.data();
          if (!invoiceSnapshot.exists || invoiceData == null) continue;
          if (invoiceData['customerId']?.toString() != clientId) continue;
          if (!_canAccessRecord(
            data: invoiceData,
            uid: uid,
            activeConnectionIds: activeConnectionIds,
          )) {
            continue;
          }
          invoiceSnapshots.add(invoiceSnapshot);
        }

        invoiceSnapshots.sort((a, b) {
          return _invoiceDate(a.data()!).compareTo(_invoiceDate(b.data()!));
        });

        final invoiceBalances = <Map<String, dynamic>>[];
        var totalOutstanding = 0.0;

        for (final invoiceSnapshot in invoiceSnapshots) {
          final data = invoiceSnapshot.data()!;
          final total = _doubleValue(data['total']);
          if (total <= 0) continue;

          final paidAmount = _normalizedPaidAmount(data, total);
          final outstanding =
              (total - paidAmount).clamp(0.0, total).toDouble();

          invoiceBalances.add({
            'snapshot': invoiceSnapshot,
            'total': total,
            'paidAmount': paidAmount,
            'outstanding': outstanding,
          });
          totalOutstanding += outstanding;
        }

        final customerBalance =
            (clientData['balance'] as num?)?.toDouble() ?? 0.0;
        final actualOrderCount = invoiceSnapshots.length;
        final actualTotalPurchases = invoiceSnapshots.fold<double>(
          0,
          (sum, invoiceSnapshot) =>
              sum +
              _doubleValue(invoiceSnapshot.data()?['total']),
        );

        // If invoice outstanding is greater than the client's current debt,
        // the difference represents historical payments which were deducted
        // from clients.balance but never applied to individual invoices.
        var previouslyRecordedPayment = totalOutstanding - customerBalance;
        if (previouslyRecordedPayment < 0) {
          previouslyRecordedPayment = 0;
        }

        var changed = 0;
        for (final invoiceBalance in invoiceBalances) {
          final invoiceSnapshot = invoiceBalance['snapshot']
              as DocumentSnapshot<Map<String, dynamic>>;
          final data = invoiceSnapshot.data()!;
          final total = invoiceBalance['total'] as double;
          final oldPaidAmount = invoiceBalance['paidAmount'] as double;
          final outstanding = invoiceBalance['outstanding'] as double;

          var appliedAmount = 0.0;
          if (previouslyRecordedPayment > 0.005 && outstanding > 0) {
            appliedAmount = previouslyRecordedPayment < outstanding
                ? previouslyRecordedPayment
                : outstanding;
            previouslyRecordedPayment -= appliedAmount;
          }

          final newPaidAmount =
              (oldPaidAmount + appliedAmount).clamp(0.0, total).toDouble();
          final newRemainingAmount =
              (total - newPaidAmount).clamp(0.0, total).toDouble();

          final storedPaid = data['paidAmount'];
          final storedRemaining = data['remainingAmount'];
          final paidNeedsUpdate = storedPaid is! num ||
              (storedPaid.toDouble() - newPaidAmount).abs() > 0.005;
          final remainingNeedsUpdate = storedRemaining is! num ||
              (storedRemaining.toDouble() - newRemainingAmount).abs() > 0.005;

          // Also repair inconsistent remainingAmount values even when the
          // aggregate client balance itself does not indicate an old payment.
          if (paidNeedsUpdate || remainingNeedsUpdate) {
            transaction.update(invoiceSnapshot.reference, {
              'paidAmount': newPaidAmount,
              'remainingAmount': newRemainingAmount,
            });
            changed++;
          }
        }

        final storedTotalPurchases = clientData['totalPurchases'];
        final storedOrderCount = clientData['orderCount'];
        final purchaseTotalNeedsUpdate = storedTotalPurchases is! num ||
            (storedTotalPurchases.toDouble() - actualTotalPurchases).abs() >
                0.005;
        final orderCountNeedsUpdate = storedOrderCount is! num ||
            storedOrderCount.toInt() != actualOrderCount;

        if (purchaseTotalNeedsUpdate || orderCountNeedsUpdate) {
          transaction.update(clientRef, {
            'totalPurchases': actualTotalPurchases,
            'orderCount': actualOrderCount,
          });
          changed++;
        }

        return changed;
      });

      updatedRecordCount += updatedForClient;
    }

    return updatedRecordCount;
  }

  Future<List<DocumentReference<Map<String, dynamic>>>>
      _invoiceReferencesForClient(
    String clientId, {
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final invoices = firestore.collection('invoices');
    final queries = <Query<Map<String, dynamic>>>[
      invoices
          .where('userId', isEqualTo: uid)
          .where('customerId', isEqualTo: clientId),
      // Legacy invoices may have userIds but no userId/sharedConnectionIds.
      invoices
          .where('userIds', arrayContains: uid)
          .where('customerId', isEqualTo: clientId),
    ];

    for (final connectionId in activeConnectionIds) {
      if (connectionId.isEmpty) continue;
      queries.add(
        invoices
            .where('sharedConnectionIds', arrayContains: connectionId)
            .where('customerId', isEqualTo: clientId),
      );
    }

    final querySnapshots = await Future.wait(queries.map((query) => query.get()));
    final references = <String, DocumentReference<Map<String, dynamic>>>{};
    for (final querySnapshot in querySnapshots) {
      for (final document in querySnapshot.docs) {
        references[document.id] = document.reference;
      }
    }
    return references.values.toList();
  }

  bool _canAccessRecord({
    required Map<String, dynamic> data,
    required String uid,
    required List<String> activeConnectionIds,
  }) {
    if (data['userId']?.toString() == uid) return true;

    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);
    if (sharedConnectionIds.any(activeConnectionIds.contains)) return true;

    return _normalizeIds(data['userIds']).contains(uid);
  }

  double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double _normalizedPaidAmount(Map<String, dynamic> data, double total) {
    final rawPaid = data['paidAmount'];
    final rawRemaining = data['remainingAmount'];

    final parsedPaid = rawPaid is num
        ? rawPaid.toDouble()
        : double.tryParse(rawPaid?.toString() ?? '');
    final parsedRemaining = rawRemaining is num
        ? rawRemaining.toDouble()
        : double.tryParse(rawRemaining?.toString() ?? '');

    final paid = parsedPaid ??
        (parsedRemaining != null ? total - parsedRemaining : 0.0);

    return paid.clamp(0.0, total).toDouble();
  }

  DateTime _invoiceDate(Map<String, dynamic> data) {
    final rawDate = data['createdAt'] ?? data['date'];
    if (rawDate is Timestamp) return rawDate.toDate();

    final value = rawDate?.toString().trim() ?? '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;

    // Legacy invoices may store dates as dd/MM/yyyy or dd/MM/yyyy hh:mm AM.
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(value);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '') ?? 1;
      final month = int.tryParse(match.group(2) ?? '') ?? 1;
      final year = int.tryParse(match.group(3) ?? '') ?? 1970;
      try {
        return DateTime(year, month, day);
      } catch (_) {
        // Fall through to the oldest-date sentinel.
      }
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
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
