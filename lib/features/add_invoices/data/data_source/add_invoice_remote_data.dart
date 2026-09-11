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
      throw Exception('User not authenticated');
    }

    return uid;
  }

  Future<String?> _getSharedAccountId() async {
    return GetIt.I<AccountSharingRepository>().getSharedAccountId();
  }

  Future<void> createInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final data = {...invoice.toJson(), 'userId': uid};

    if (sharedAccountId != null) {
      data['sharedAccountId'] = sharedAccountId;
    }

    await firestore.collection('invoices').doc(invoice.invoiceId).set(data);
  }

  Future<void> finalizeInvoice(InvoiceModel invoice) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final invoiceRef = firestore.collection('invoices').doc(invoice.invoiceId);

    final clientRef = firestore.collection('clients').doc(invoice.customerId);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      if (invoiceSnapshot.exists) {
        final data = invoiceSnapshot.data();

        final invoiceUserId = data?['userId']?.toString();

        if (invoiceUserId == null || invoiceUserId.isEmpty) {
          throw Exception('Invoice not found');
        }

        if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
          final docSharedId = data?['sharedAccountId']?.toString();
          if (docSharedId != sharedAccountId) {
            throw Exception('Invoice not found');
          }
        } else {
          if (invoiceUserId != uid) {
            throw Exception('Invoice not found');
          }
        }

        if (data?['stockDeducted'] == true) {
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
        throw Exception('Client not found');
      }

      final clientData = clientSnapshot.data() ?? {};

      final clientUserId = clientData['userId']?.toString();

      if (clientUserId == null || clientUserId.isEmpty) {
        throw Exception('Client not found');
      }

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final docSharedId = clientData['sharedAccountId']?.toString();
        if (docSharedId != sharedAccountId) {
          throw Exception('Client not found');
        }
      } else {
        if (clientUserId != uid) {
          throw Exception('Client not found');
        }
      }

      final Map<String, DocumentSnapshot<Map<String, dynamic>>> products = {};

      for (final productId in quantities.keys) {
        final productRef = firestore.collection('products').doc(productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('Product not found: $productId');
        }

        final productData = productSnapshot.data() ?? {};

        final productUserId = productData['userId']?.toString();

        if (productUserId == null || productUserId.isEmpty) {
          throw Exception('Product not found: $productId');
        }

        if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
          final docSharedId = productData['sharedAccountId']?.toString();
          if (docSharedId != sharedAccountId) {
            throw Exception('Product not found: $productId');
          }
        } else {
          if (productUserId != uid) {
            throw Exception('Product not found: $productId');
          }
        }

        products[productId] = productSnapshot;
      }

      for (final entry in quantities.entries) {
        final productId = entry.key;
        final requestedQuantity = entry.value;

        final productData = products[productId]!.data();

        final availableQuantity =
            (productData?['quantity'] as num?)?.toInt() ?? 0;

        if (requestedQuantity > availableQuantity) {
          throw Exception(
            'Not enough stock. Available: '
            '$availableQuantity, '
            'Requested: $requestedQuantity',
          );
        }
      }

      final currentBalance = (clientData['balance'] as num?) ?? 0;

      final currentTotalPurchases = (clientData['totalPurchases'] as num?) ?? 0;

      final currentOrderCount = (clientData['orderCount'] as num?) ?? 0;

      final remainingAmount = invoice.remainingAmount;

      final newBalance = currentBalance + remainingAmount;

      final invoiceData = {
        ...invoice.toJson(),
        'userId': uid,
        'stockDeducted': true,
      };

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        invoiceData['sharedAccountId'] = sharedAccountId;
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

        invoices.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt);

          final dateB = DateTime.tryParse(b.createdAt);

          if (dateA == null || dateB == null) {
            return 0;
          }

          return dateB.compareTo(dateA);
        });

        return invoices;
      });
    });
  }

  Stream<List<InvoiceModel>> watchClientInvoices(String customerId) {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((sharedAccountId) {
      Query<Map<String, dynamic>> query = firestore.collection('invoices');

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        query = query
            .where('sharedAccountId', isEqualTo: sharedAccountId)
            .where('customerId', isEqualTo: customerId);
      } else {
        query = query
            .where('userId', isEqualTo: uid)
            .where('customerId', isEqualTo: customerId);
      }

      return query.snapshots().map((snapshot) {
        final invoices = snapshot.docs
            .map((doc) => InvoiceModel.fromJson(doc.data()))
            .toList();

        invoices.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt);

          final dateB = DateTime.tryParse(b.createdAt);

          if (dateA == null || dateB == null) {
            return 0;
          }

          return dateB.compareTo(dateA);
        });

        return invoices.take(5).toList();
      });
    });
  }

  Future<InvoiceModel?> getInvoice(String invoiceId) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final doc = await firestore.collection('invoices').doc(invoiceId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;

    final invoiceUserId = data['userId']?.toString();

    if (invoiceUserId == null || invoiceUserId.isEmpty) {
      return null;
    }

    if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
      final docSharedId = data['sharedAccountId']?.toString();
      if (docSharedId != sharedAccountId) {
        return null;
      }
    } else {
      if (invoiceUserId != uid) {
        return null;
      }
    }

    return InvoiceModel.fromJson(data);
  }

  Future<void> checkStock(InvoiceModel invoice) async {
    await _getSharedAccountId();

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
        throw Exception('Product not found');
      }

      final data = productSnapshot.data() ?? {};

      final productUserId = data['userId']?.toString();

      if (productUserId == null || productUserId.isEmpty) {
        throw Exception('Product not found');
      }

      final availableQuantity = (data['quantity'] as num?)?.toInt() ?? 0;

      if (entry.value > availableQuantity) {
        throw Exception(
          '${'Not enough stock. Available:'.tr()} '
          '$availableQuantity, '
          '${'Requested:'.tr()} ${entry.value}',
        );
      }
    }
  }

  Stream<List<InvoiceModel>> watchAllClientInvoices(String customerId) {
    final uid = _currentUserId;

    return GetIt.I<AccountSharingRepository>()
        .watchSharedAccountId()
        .asyncExpand((sharedAccountId) {
      Query<Map<String, dynamic>> query = firestore.collection('invoices');

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        query = query
            .where('sharedAccountId', isEqualTo: sharedAccountId)
            .where('customerId', isEqualTo: customerId);
      } else {
        query = query
            .where('userId', isEqualTo: uid)
            .where('customerId', isEqualTo: customerId);
      }

      return query.snapshots().map((snapshot) {
        final invoices = snapshot.docs
            .map((doc) => InvoiceModel.fromJson(doc.data()))
            .toList();

        invoices.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt);

          final dateB = DateTime.tryParse(b.createdAt);

          if (dateA == null || dateB == null) {
            return 0;
          }

          return dateB.compareTo(dateA);
        });

        return invoices;
      });
    });
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final uid = _currentUserId;
    final sharedAccountId = await _getSharedAccountId();

    final invoiceRef = firestore.collection('invoices').doc(invoiceId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(invoiceRef);

      if (!snapshot.exists) {
        throw Exception('Invoice not found');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Invoice not found');
      }

      final invoiceUserId = data['userId']?.toString();

      if (invoiceUserId == null || invoiceUserId.isEmpty) {
        throw Exception('Invoice not found');
      }

      if (sharedAccountId != null && sharedAccountId.isNotEmpty) {
        final docSharedId = data['sharedAccountId']?.toString();
        if (docSharedId != sharedAccountId) {
          throw Exception('Invoice not found');
        }
      } else {
        if (invoiceUserId != uid) {
          throw Exception('Invoice not found');
        }
      }

      transaction.delete(invoiceRef);
    });
  }
}
