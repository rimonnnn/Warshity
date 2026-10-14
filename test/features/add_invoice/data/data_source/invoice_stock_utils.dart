import 'package:easy_localization/easy_localization.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';

/// أدوات تجميع الكميات والتحقق من المخزون.
class InvoiceStockUtils {
  const InvoiceStockUtils._();

  /// يجمع كميات المنتجات المتكررة في الفاتورة.
  static Map<String, int> aggregateQuantities(InvoiceModel invoice) {
    final quantities = <String, int>{};

    for (final item in invoice.items) {
      quantities[item.productId] =
          (quantities[item.productId] ?? 0) + item.quantity;
    }

    return quantities;
  }

  static void ensureAvailable({
    required int available,
    required int requested,
  }) {
    if (requested > available) {
      throw Exception(
        '${'not_enough_stock_available'.tr()} '
        '$available. '
        '${'requested'.tr()} '
        '$requested',
      );
    }
  }

  static int quantityOf(Map<String, dynamic>? productData) {
    return (productData?['quantity'] as num?)?.toInt() ?? 0;
  }
}
