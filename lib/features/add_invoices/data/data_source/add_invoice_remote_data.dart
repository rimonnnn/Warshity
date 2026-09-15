import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/account_sharing/data/repositories/account_sharing_repository.dart';

class InvoicesRemoteDataSource {
  final FirebaseFirestore firestore;

  InvoicesRemoteDataSource(this.firestore);

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

  Future<bool> _hasAccessToInvoice(Map<String, dynamic> data) async {
    final uid = _currentUserId;

    final ownerUid = data['userId']?.toString();

    if (ownerUid == uid) {
      return true;
    }

    final activeConnectionIds = await _getActiveConnectionIds();

    if (activeConnectionIds.isEmpty) {
      return false;
    }

    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isNotEmpty) {
      return sharedConnectionIds.any(activeConnectionIds.contains);
    }

    final legacyUserIds = _normalizeIds(data['userIds']);

    return legacyUserIds.contains(uid);
  }
  Future<bool> _hasAccessToProduct(Map<String, dynamic> data) async {
    final uid = _currentUserId;

    final ownerUid = data['userId']?.toString();

    if (ownerUid == uid) {
      return true;
    }

    final activeConnectionIds = await _getActiveConnectionIds();

    if (activeConnectionIds.isEmpty) {
      return false;
    }

    final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

    if (sharedConnectionIds.isNotEmpty) {
      return sharedConnectionIds.any(activeConnectionIds.contains);
    }

    final legacyUserIds = _normalizeIds(data['userIds']);

    return legacyUserIds.contains(uid);
  }

  Future<void> createInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;

    final connectionIds = await _getActiveConnectionIds();

    final ref = firestore.collection('invoices').doc(invoice.invoiceId);

    final data = <String, dynamic>{
      ...invoice.toJson(),
      'userId': uid,
      'userIds': <String>[uid],
      'sharedConnectionIds': connectionIds,
      'sharedDataId': ref.id,
    };

    data.remove('sharedAccountId');

    await ref.set(data);
  }

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;

    final activeConnectionIds = await _getActiveConnectionIds();

    final invoiceRef = firestore.collection('invoices').doc(invoice.invoiceId);

    final clientRef = firestore.collection('clients').doc(invoice.customerId);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      Map<String, dynamic>? existingInvoiceData;

      if (invoiceSnapshot.exists) {
        existingInvoiceData = invoiceSnapshot.data();

        final invoiceUserId = existingInvoiceData?['userId']?.toString();

        if (invoiceUserId == null || invoiceUserId.isEmpty) {
          throw Exception('invoice_not_found'.tr());
        }

        final invoiceSharedIds = _normalizeIds(
          existingInvoiceData?['sharedConnectionIds'],
        );

        var invoiceHasAccess = invoiceUserId == uid;

        if (!invoiceHasAccess && invoiceSharedIds.isNotEmpty) {
          invoiceHasAccess = invoiceSharedIds.any(activeConnectionIds.contains);
        }

        if (!invoiceHasAccess && invoiceSharedIds.isEmpty) {
          final legacyUserIds = _normalizeIds(existingInvoiceData?['userIds']);

          invoiceHasAccess = legacyUserIds.contains(uid);
        }

        if (!invoiceHasAccess) {
          throw Exception('invoice_not_found'.tr());
        }

        if (existingInvoiceData?['stockDeducted'] == true) {
          return;
        }
      }

      final quantities = <String, int>{};

      for (final item in invoice.items) {
        quantities[item.productId] =
            (quantities[item.productId] ?? 0) + item.quantity;
      }

      final clientSnapshot = await transaction.get(clientRef);

      if (!clientSnapshot.exists) {
        throw Exception('client_not_found'.tr());
      }

      final clientData = clientSnapshot.data() ?? {};

      final clientUserId = clientData['userId']?.toString();

      if (clientUserId == null || clientUserId.isEmpty) {
        throw Exception('client_not_found'.tr());
      }

      final clientSharedIds = _normalizeIds(clientData['sharedConnectionIds']);

      var clientHasAccess = clientUserId == uid;

      if (!clientHasAccess && clientSharedIds.isNotEmpty) {
        clientHasAccess = clientSharedIds.any(activeConnectionIds.contains);
      }

      if (!clientHasAccess && clientSharedIds.isEmpty) {
        final legacyUserIds = _normalizeIds(clientData['userIds']);

        clientHasAccess = legacyUserIds.contains(uid);
      }

      if (!clientHasAccess) {
        throw Exception('client_not_found'.tr());
      }

      final products = <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final productId in quantities.keys) {
        final productRef = firestore.collection('products').doc(productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('product_not_found'.tr());
        }

        final productData = productSnapshot.data() ?? {};

        final productUserId = productData['userId']?.toString();

        if (productUserId == null || productUserId.isEmpty) {
          throw Exception('product_not_found'.tr());
        }

        final productSharedIds = _normalizeIds(
          productData['sharedConnectionIds'],
        );

        var productHasAccess = productUserId == uid;

        if (!productHasAccess && productSharedIds.isNotEmpty) {
          productHasAccess = productSharedIds.any(activeConnectionIds.contains);
        }

        if (!productHasAccess && productSharedIds.isEmpty) {
          final legacyUserIds = _normalizeIds(productData['userIds']);

          productHasAccess = legacyUserIds.contains(uid);
        }

        if (!productHasAccess) {
          throw Exception('product_not_found'.tr());
        }

        products[productId] = productSnapshot;
      }

      for (final entry in quantities.entries) {
        final productData = products[entry.key]!.data();

        final availableQuantity =
            (productData?['quantity'] as num?)?.toInt() ?? 0;

        if (entry.value > availableQuantity) {
          throw Exception(
            '${'not_enough_stock_available'.tr()} '
            '$availableQuantity. '
            '${'requested'.tr()} '
            '${entry.value}',
          );
        }
      }

      final currentBalance = (clientData['balance'] as num?) ?? 0;

      final currentTotalPurchases = (clientData['totalPurchases'] as num?) ?? 0;

      final currentOrderCount = (clientData['orderCount'] as num?) ?? 0;

      final remainingAmount = invoice.remainingAmount;

      final newBalance = currentBalance + remainingAmount;

      final existingSharedDataId = existingInvoiceData?['sharedDataId']
          ?.toString();

      final invoiceData = <String, dynamic>{
        ...invoice.toJson(),
        'userId': uid,
        'userIds': <String>[uid],
        'sharedConnectionIds': activeConnectionIds,
        'stockDeducted': true,
        'sharedDataId':
            existingSharedDataId != null && existingSharedDataId.isNotEmpty
            ? existingSharedDataId
            : invoice.invoiceId,
      };

      invoiceData.remove('sharedAccountId');

      transaction.set(invoiceRef, invoiceData);

      for (final entry in quantities.entries) {
        final productRef = firestore.collection('products').doc(entry.key);

        transaction.update(productRef, {
          'quantity': FieldValue.increment(-entry.value),
        });
      }

      transaction.update(clientRef, {
        'totalPurchases': currentTotalPurchases + invoice.total,
        'orderCount': currentOrderCount + 1,
        if (remainingAmount > 0) ...{
          'balance': newBalance,
          'hasDebt': newBalance > 0,
        },
      });
    });
  }

  Stream<List<InvoiceModel>> watchInvoices() {
    final uid = _currentUserId;

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
        return streams.first.map(_mapInvoiceSnapshot);
      }

      return Stream.multi((controller) {
        final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          final invoices = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => InvoiceModel.fromJson(doc.data()!))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(invoices);
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

  Stream<List<InvoiceModel>> watchClientInvoices(String customerId) {
    final uid = _currentUserId;

    return _sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('invoices')
            .where('userId', isEqualTo: uid)
            .where('customerId', isEqualTo: customerId)
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
              .where('customerId', isEqualTo: customerId)
              .snapshots(),
        );
      }

      if (streams.length == 1) {
        return streams.first.map((snapshot) {
          final invoices = snapshot.docs
              .map((doc) => InvoiceModel.fromJson(doc.data()))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return invoices.take(5).toList();
        });
      }

      return Stream.multi((controller) {
        final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          final invoices = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => InvoiceModel.fromJson(doc.data()!))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(invoices.take(5).toList());
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

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final doc = await firestore.collection('invoices').doc(invoiceId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    final hasAccess = await _hasAccessToInvoice(data);

    if (!hasAccess) {
      return null;
    }

    return InvoiceModel.fromJson(data);
  }

  Future<void> checkStock(InvoiceModel invoice) async {
    final Map<String, int> quantities = {};

    for (final item in invoice.items) {
      quantities[item.productId] =
          (quantities[item.productId] ?? 0) + item.quantity;
    }

    for (final entry in quantities.entries) {
      final productSnapshot = await firestore
          .collection('products')
          .doc(entry.key)
          .get();

      if (!productSnapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = productSnapshot.data() ?? {};

      final productUserId = data['userId']?.toString();

      if (productUserId == null || productUserId.isEmpty) {
        throw Exception('product_not_found'.tr());
      }

      final hasAccess = await _hasAccessToProduct(data);

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      final availableQuantity = (data['quantity'] as num?)?.toInt() ?? 0;

      if (entry.value > availableQuantity) {
        throw Exception(
          '${'not_enough_stock_available'.tr()} '
          '$availableQuantity. '
          '${'requested'.tr()} '
          '${entry.value}',
        );
      }
    }
  }

  Stream<List<InvoiceModel>> watchAllClientInvoices(String customerId) {
    final uid = _currentUserId;

    return _sharingRepository.watchActiveConnectionIds().asyncExpand((
      connectionIds,
    ) {
      final streams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

      streams.add(
        firestore
            .collection('invoices')
            .where('userId', isEqualTo: uid)
            .where('customerId', isEqualTo: customerId)
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
              .where('customerId', isEqualTo: customerId)
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
        final documents = <String, DocumentSnapshot<Map<String, dynamic>>>{};

        final subscriptions =
            <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

        void emit() {
          final invoices = documents.values
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => InvoiceModel.fromJson(doc.data()!))
              .toList();

          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          controller.add(invoices);
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

  Future<void> deleteInvoice(String invoiceId) async {
    final uid = _currentUserId;

    final invoiceRef = firestore.collection('invoices').doc(invoiceId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(invoiceRef);

      if (!snapshot.exists) {
        throw Exception('invoice_not_found'.tr());
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('invoice_not_found'.tr());
      }

      final invoiceUserId = data['userId']?.toString();

      if (invoiceUserId == null || invoiceUserId.isEmpty) {
        throw Exception('invoice_not_found'.tr());
      }

      final activeConnectionIds = await _getActiveConnectionIds();

      var hasAccess = invoiceUserId == uid;

      final sharedConnectionIds = _normalizeIds(data['sharedConnectionIds']);

      if (!hasAccess && sharedConnectionIds.isNotEmpty) {
        hasAccess = sharedConnectionIds.any(activeConnectionIds.contains);
      }

      if (!hasAccess && sharedConnectionIds.isEmpty) {
        final legacyUserIds = _normalizeIds(data['userIds']);

        hasAccess = legacyUserIds.contains(uid);
      }

      if (!hasAccess) {
        throw Exception('invoice_not_found'.tr());
      }

      final customerId = data['customerId']?.toString() ?? '';

      if (customerId.isNotEmpty) {
        final clientRef = firestore.collection('clients').doc(customerId);

        final clientSnapshot = await transaction.get(clientRef);

        if (!clientSnapshot.exists) {
          throw Exception('client_not_found'.tr());
        }
      }

      transaction.delete(invoiceRef);
    });
  }

  List<InvoiceModel> _mapInvoiceSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final invoices = snapshot.docs
        .map((doc) => InvoiceModel.fromJson(doc.data()))
        .toList();

    invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return invoices;
  }
}
