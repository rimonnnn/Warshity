import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'invoice_access_checker.dart';
import 'invoice_stock_utils.dart';

/// تنفيذ معاملة اعتماد الفاتورة (خصم المخزون + تحديث العميل).
class InvoiceFinalizer {
  final FirebaseFirestore firestore;

  InvoiceFinalizer(this.firestore);

  Future<void> finalize({
    required InvoiceModel invoice,
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final invoiceRef = firestore.collection('invoices').doc(invoice.invoiceId);
    final clientRef = firestore.collection('clients').doc(invoice.customerId);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      Map<String, dynamic>? existingInvoiceData;

      if (invoiceSnapshot.exists) {
        existingInvoiceData = invoiceSnapshot.data();

        InvoiceAccessChecker.ensureAccess(
          data: existingInvoiceData,
          uid: uid,
          activeConnectionIds: activeConnectionIds,
          errorKey: 'invoice_not_found',
        );

        if (existingInvoiceData?['stockDeducted'] == true) {
          return;
        }
      }

      final quantities = InvoiceStockUtils.aggregateQuantities(invoice);

      final clientData = await _readAccessible(
        transaction,
        clientRef,
        uid,
        activeConnectionIds,
        'client_not_found',
      );

      final products = <String, Map<String, dynamic>>{};

      for (final productId in quantities.keys) {
        products[productId] = await _readAccessible(
          transaction,
          firestore.collection('products').doc(productId),
          uid,
          activeConnectionIds,
          'product_not_found',
        );
      }

      for (final entry in quantities.entries) {
        InvoiceStockUtils.ensureAvailable(
          available: InvoiceStockUtils.quantityOf(products[entry.key]),
          requested: entry.value,
        );
      }

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
        transaction.update(firestore.collection('products').doc(entry.key), {
          'quantity': FieldValue.increment(-entry.value),
        });
      }

      _updateClient(transaction, clientRef, clientData, invoice);
    });
  }

  void _updateClient(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> clientRef,
    Map<String, dynamic> clientData,
    InvoiceModel invoice,
  ) {
    final currentBalance = (clientData['balance'] as num?) ?? 0;
    final currentTotalPurchases = (clientData['totalPurchases'] as num?) ?? 0;
    final currentOrderCount = (clientData['orderCount'] as num?) ?? 0;

    final remainingAmount = invoice.remainingAmount;
    final newBalance = currentBalance + remainingAmount;

    transaction.update(clientRef, {
      'totalPurchases': currentTotalPurchases + invoice.total,
      'orderCount': currentOrderCount + 1,
      if (remainingAmount > 0) ...{
        'balance': newBalance,
        'hasDebt': newBalance > 0,
      },
    });
  }

  /// يقرأ مستنداً داخل المعاملة ويتحقق من وجوده وصلاحية الوصول إليه.
  Future<Map<String, dynamic>> _readAccessible(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> ref,
    String uid,
    List<String> activeConnectionIds,
    String notFoundKey,
  ) async {
    final snapshot = await transaction.get(ref);

    if (!snapshot.exists) {
      throw Exception(notFoundKey.tr());
    }

    final data = snapshot.data() ?? {};

    InvoiceAccessChecker.ensureAccess(
      data: data,
      uid: uid,
      activeConnectionIds: activeConnectionIds,
      errorKey: notFoundKey,
    );

    return data;
  }
}
