import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'invoice_access_checker.dart';
import 'invoice_stock_utils.dart';

/// التحقق من توفر المخزون لكل منتجات الفاتورة (خارج المعاملات).
class InvoiceStockChecker {
  final FirebaseFirestore firestore;

  InvoiceStockChecker(this.firestore);

  Future<void> check({
    required InvoiceModel invoice,
    required String uid,
    required List<String> activeConnectionIds,
  }) async {
    final quantities = InvoiceStockUtils.aggregateQuantities(invoice);

    for (final entry in quantities.entries) {
      final snapshot = await firestore
          .collection('products')
          .doc(entry.key)
          .get();

      if (!snapshot.exists) {
        throw Exception('product_not_found'.tr());
      }

      final data = snapshot.data() ?? {};

      final productUserId = data['userId']?.toString();

      if (productUserId == null || productUserId.isEmpty) {
        throw Exception('product_not_found'.tr());
      }

      final hasAccess = InvoiceAccessChecker.hasAccess(
        data: data,
        uid: uid,
        activeConnectionIds: activeConnectionIds,
        requireActiveConnections: true,
      );

      if (!hasAccess) {
        throw Exception('product_not_found'.tr());
      }

      InvoiceStockUtils.ensureAvailable(
        available: InvoiceStockUtils.quantityOf(data),
        requested: entry.value,
      );
    }
  }
}
