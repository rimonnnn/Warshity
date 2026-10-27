import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/core/errors/app_failure.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

class InvoicesRemoteDataSources {
  final FirebaseFirestore firestore;

  InvoicesRemoteDataSources(this.firestore);

  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('user_not_authenticated'.tr());
    }

    return uid;
  }

  AccountSharingRepository get _sharingRepository =>
      GetIt.I<AccountSharingRepository>();

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

  Future<List<String>> _getActiveConnectionIds() async {
    return _sharingRepository.getActiveConnectionIds();
  }

  bool _hasSharedConnectionAccess({
    required Map<String, dynamic> data,
    required List<String> activeConnectionIds,
  }) {
    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isEmpty || activeConnectionIds.isEmpty) {
      return false;
    }

    return sharedConnectionIds.any(activeConnectionIds.contains);
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      // Never throw during widget build: report as a stream error instead.
      return Stream.error(const UnauthenticatedException());
    }

    return _sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('invoices')
            .where('userId', isEqualTo: uid)
            .snapshots(),
      );

      for (final connectionId in connectionIds) {
        if (connectionId.isEmpty) {
          continue;
        }

        streams.add(
          firestore
              .collection('invoices')
              .where('sharedConnectionIds', arrayContains: connectionId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map((snapshot) {
          final invoices = snapshot.docs
              .map((doc) => InvoiceModel.fromJson(doc.data()))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return invoices;
        });
      }

      return Stream.multi((controller) {
        // Each query owns its own result set. A document may match more than
        // one query, so removing it from one query must not remove it globally.
        final documentsByQuery =
            List<Map<String, DocumentSnapshot<Map<String, dynamic>>>>.generate(
          streams.length,
          (_) => <String, DocumentSnapshot<Map<String, dynamic>>>{},
        );
        final initialSnapshotsReceived = List<bool>.filled(
          streams.length,
          false,
        );

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          // .first consumers (for example search) must receive the union only
          // after every query has supplied its initial snapshot.
          if (initialSnapshotsReceived.any((received) => !received)) {
            return;
          }

          final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};
          for (final queryDocuments in documentsByQuery) {
            documents.addAll(queryDocuments);
          }
          final invoices = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => InvoiceModel.fromJson(doc.data()!))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(invoices);
        }

        for (var streamIndex = 0; streamIndex < streams.length; streamIndex++) {
          final stream = streams[streamIndex];
          final subscription = stream.listen((snapshot) {
            final queryDocuments = documentsByQuery[streamIndex];
            queryDocuments
              ..clear()
              ..addEntries(
                snapshot.docs.map((doc) => MapEntry(doc.id, doc)),
              );
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

  Future<void> deleteInvoice(String invoiceId) async {
    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final invoiceRef = firestore.collection('invoices').doc(invoiceId);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      if (!invoiceSnapshot.exists) {
        throw Exception('invoice_not_found'.tr());
      }

      final invoiceData = invoiceSnapshot.data();

      if (invoiceData == null) {
        throw Exception('invoice_data_not_found'.tr());
      }

      final invoiceUserId = invoiceData['userId']?.toString();

      final isOwner = invoiceUserId == uid;

      final hasSharedAccess = _hasSharedConnectionAccess(
        data: invoiceData,
        activeConnectionIds: activeConnectionIds,
      );

      if (!isOwner && !hasSharedAccess) {
        final legacyUserIds = _normalizeIds(invoiceData['userIds']);

        final legacyAccess = legacyUserIds.contains(uid);

        if (!legacyAccess) {
          throw Exception('invoice_not_found'.tr());
        }
      }

      final customerId = invoiceData['customerId']?.toString() ?? '';

      final total = (invoiceData['total'] as num?)?.toDouble() ?? 0.0;

      final remainingAmount =
          (invoiceData['remainingAmount'] as num?)?.toDouble() ?? 0.0;

      final stockDeducted = invoiceData['stockDeducted'] == true;

      DocumentSnapshot<Map<String, dynamic>>? clientSnapshot;

      if (customerId.isNotEmpty) {
        final clientRef = firestore.collection('clients').doc(customerId);

        clientSnapshot = await transaction.get(clientRef);

        if (!clientSnapshot.exists) {
          throw Exception('client_not_found'.tr());
        }

        final clientData = clientSnapshot.data() ?? {};

        final clientUserId = clientData['userId']?.toString();

        final clientIsOwner = clientUserId == uid;

        final clientSharedAccess = _hasSharedConnectionAccess(
          data: clientData,
          activeConnectionIds: activeConnectionIds,
        );

        var clientHasAccess = clientIsOwner || clientSharedAccess;

        if (!clientHasAccess) {
          final legacyUserIds = _normalizeIds(clientData['userIds']);

          clientHasAccess = legacyUserIds.contains(uid);
        }

        if (!clientHasAccess) {
          throw Exception('client_not_found'.tr());
        }
      }

      final quantities = <String, int>{};

      if (stockDeducted) {
        final items = invoiceData['items'];

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

      for (final productId in quantities.keys) {
        final productRef = firestore.collection('products').doc(productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('product_not_found'.tr());
        }

        final productData = productSnapshot.data() ?? {};

        final productUserId = productData['userId']?.toString();

        final productIsOwner = productUserId == uid;

        final productSharedAccess = _hasSharedConnectionAccess(
          data: productData,
          activeConnectionIds: activeConnectionIds,
        );

        var productHasAccess = productIsOwner || productSharedAccess;

        if (!productHasAccess) {
          final legacyUserIds = _normalizeIds(productData['userIds']);

          productHasAccess = legacyUserIds.contains(uid);
        }

        if (!productHasAccess) {
          throw Exception('product_not_found'.tr());
        }
      }

      if (clientSnapshot != null) {
        final clientData = clientSnapshot.data() ?? {};

        final currentTotalPurchases =
            (clientData['totalPurchases'] as num?) ?? 0;

        final currentOrderCount = (clientData['orderCount'] as num?) ?? 0;

        final currentBalance = (clientData['balance'] as num?) ?? 0;

        final newTotalPurchases = (currentTotalPurchases - total).clamp(
          0,
          double.infinity,
        );

        final newOrderCount = (currentOrderCount - 1).clamp(0, double.infinity);

        final newBalance = (currentBalance - remainingAmount).clamp(
          0,
          double.infinity,
        );

        transaction.update(firestore.collection('clients').doc(customerId), {
          'totalPurchases': newTotalPurchases,
          'orderCount': newOrderCount,
          'balance': newBalance,
          'hasDebt': newBalance > 0,
        });
      }

      for (final entry in quantities.entries) {
        final productRef = firestore.collection('products').doc(entry.key);

        transaction.update(productRef, {
          'quantity': FieldValue.increment(entry.value),
        });
      }

      transaction.delete(invoiceRef);
    });
  }
}
