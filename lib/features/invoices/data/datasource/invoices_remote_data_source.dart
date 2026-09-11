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

  Stream<List<InvoiceModel>> watchInvoices() {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((sharedAccountId) {
      Query<Map<String, dynamic>> query = firestore.collection('invoices');

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        query = query.where(
          'sharedAccountId',
          isEqualTo: sharedAccountId,
        );
      } else {
        query = query.where('userId', isEqualTo: uid);
      }

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
    final sharedAccountId = await _getSharedAccountId();

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

      if (invoiceUserId == null || invoiceUserId.isEmpty) {
        throw Exception('invoice_not_found'.tr());
      }

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final docSharedId = invoiceData['sharedAccountId']?.toString();
        if (docSharedId != sharedAccountId) {
          throw Exception('invoice_not_found'.tr());
        }
      } else {
        if (invoiceUserId != uid) {
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

        if (clientUserId == null || clientUserId.isEmpty) {
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

      final Map<String, DocumentSnapshot<Map<String, dynamic>>>
      productSnapshots = {};

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

        productSnapshots[productId] = productSnapshot;
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
