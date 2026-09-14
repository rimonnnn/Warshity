import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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

  Future<String?> _getSharedAccountId() async {
    return GetIt.I<AccountSharingRepository>().getSharedAccountId();
  }

  // ignore: unused_element
  Future<List<String>> _getUserIds() async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    if (sharedAccountId == null || sharedAccountId.isEmpty) {
      return [uid];
    }

    final snapshot = await firestore
        .collection('shared_accounts')
        .doc(sharedAccountId)
        .get();

    if (!snapshot.exists) {
      return [uid];
    }

    final data = snapshot.data() ?? {};

    final members =
        (data['members'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    if (!members.contains(uid)) {
      members.add(uid);
    }

    return members.toSet().toList();
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

  Future<void> deleteInvoice(String invoiceId) async {
    final uid = _currentUserId;

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

      final invoiceUserIds = (invoiceData['userIds'] as List?)
          ?.map((e) => e.toString())
          .toList();

      final invoiceUserId = invoiceData['userId']?.toString();

      final hasAccess =
          invoiceUserIds?.contains(uid) == true || invoiceUserId == uid;

      if (!hasAccess) {
        throw Exception('invoice_not_found'.tr());
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

        final clientUserIds = (clientData['userIds'] as List?)
            ?.map((e) => e.toString())
            .toList();

        final clientUserId = clientData['userId']?.toString();

        final clientHasAccess =
            clientUserIds?.contains(uid) == true || clientUserId == uid;

        if (!clientHasAccess) {
          throw Exception('client_not_found'.tr());
        }
      }

      final Map<String, int> quantities = {};

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

        final productUserIds = (productData['userIds'] as List?)
            ?.map((e) => e.toString())
            .toList();

        final productUserId = productData['userId']?.toString();

        final productHasAccess =
            productUserIds?.contains(uid) == true || productUserId == uid;

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
