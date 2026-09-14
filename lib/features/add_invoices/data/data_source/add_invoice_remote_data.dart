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

  Future<String?> _getSharedAccountId() async {
    return GetIt.I<AccountSharingRepository>().getSharedAccountId();
  }

  Future<List<String>> _getSharedMembers(String sharedAccountId) async {
    final snapshot = await firestore
        .collection('shared_accounts')
        .doc(sharedAccountId)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return [_currentUserId];
    }

    final members = snapshot.data()?['members'];

    if (members is! List) {
      return [_currentUserId];
    }

    final ids = members
        .map((e) => e.toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (!ids.contains(_currentUserId)) {
      ids.add(_currentUserId);
    }

    return ids;
  }

  Future<void> createInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final ref = firestore.collection('invoices').doc(invoice.invoiceId);

    final data = <String, dynamic>{
      ...invoice.toJson(),
      'userId': uid,
      'userIds': <String>[uid],
      'sharedDataId': ref.id,
    };

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      final members = await _getSharedMembers(sharedAccountId);

      data['sharedAccountId'] = sharedAccountId;
      data['userIds'] = members;
    }

    await ref.set(data);
  }

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

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

        final userIds = existingInvoiceData?['userIds'];

        if (userIds is List) {
          final allowed = userIds.map((e) => e.toString()).contains(uid);

          if (!allowed && invoiceUserId != uid) {
            throw Exception('invoice_not_found'.tr());
          }
        } else if (invoiceUserId != uid) {
          throw Exception('invoice_not_found'.tr());
        }

        if (existingInvoiceData?['stockDeducted'] == true) {
          return;
        }
      }

      final Map<String, int> quantities = {};

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

      final clientUserIds = clientData['userIds'];

      if (clientUserIds is List) {
        final allowed = clientUserIds.map((e) => e.toString()).contains(uid);

        if (!allowed && clientUserId != uid) {
          throw Exception('client_not_found'.tr());
        }
      } else if (clientUserId != uid) {
        throw Exception('client_not_found'.tr());
      }

      final Map<String, DocumentSnapshot<Map<String, dynamic>>> products = {};

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

        final productUserIds = productData['userIds'];

        if (productUserIds is List) {
          final allowed = productUserIds.map((e) => e.toString()).contains(uid);

          if (!allowed && productUserId != uid) {
            throw Exception('product_not_found'.tr());
          }
        } else if (productUserId != uid) {
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
        'stockDeducted': true,
        'sharedDataId':
            existingSharedDataId != null && existingSharedDataId.isNotEmpty
            ? existingSharedDataId
            : invoice.invoiceId,
      };

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final members = await _getSharedMembers(sharedAccountId);

        invoiceData['sharedAccountId'] = sharedAccountId;

        invoiceData['userIds'] = members;
      }

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

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((_) {
          final query = firestore
              .collection('invoices')
              .where('userIds', arrayContains: uid);

          return query.snapshots().map((snapshot) {
            final invoices = snapshot.docs
                .map((doc) => InvoiceModel.fromJson(doc.data()))
                .toList();

            invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return invoices;
          });
        });
  }

  Stream<List<InvoiceModel>> watchClientInvoices(String customerId) {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((_) {
          final query = firestore
              .collection('invoices')
              .where('userIds', arrayContains: uid)
              .where('customerId', isEqualTo: customerId);

          return query.snapshots().map((snapshot) {
            final invoices = snapshot.docs
                .map((doc) => InvoiceModel.fromJson(doc.data()))
                .toList();

            invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return invoices.take(5).toList();
          });
        });
  }

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final uid = _currentUserId;

    final doc = await firestore.collection('invoices').doc(invoiceId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    final invoiceUserId = data['userId']?.toString();

    if (invoiceUserId == null || invoiceUserId.isEmpty) {
      return null;
    }

    final userIds = data['userIds'];

    if (userIds is List) {
      final allowed = userIds.map((e) => e.toString()).contains(uid);

      if (!allowed && invoiceUserId != uid) {
        return null;
      }
    } else if (invoiceUserId != uid) {
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

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((_) {
          final query = firestore
              .collection('invoices')
              .where('userIds', arrayContains: uid)
              .where('customerId', isEqualTo: customerId);

          return query.snapshots().map((snapshot) {
            final invoices = snapshot.docs
                .map((doc) => InvoiceModel.fromJson(doc.data()))
                .toList();

            invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return invoices;
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

      final userIds = data['userIds'];

      if (userIds is List) {
        final allowed = userIds.map((e) => e.toString()).contains(uid);

        if (!allowed && invoiceUserId != uid) {
          throw Exception('invoice_not_found'.tr());
        }
      } else if (invoiceUserId != uid) {
        throw Exception('invoice_not_found'.tr());
      }

      final customerId = data['customerId']?.toString() ?? '';

      final clientRef = firestore.collection('clients').doc(customerId);

      if (customerId.isNotEmpty) {
        final clientSnapshot = await transaction.get(clientRef);

        if (!clientSnapshot.exists) {
          throw Exception('client_not_found'.tr());
        }
      }

      transaction.delete(invoiceRef);
    });
  }
}