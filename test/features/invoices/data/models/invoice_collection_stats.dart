import 'package:warshity/features/invoices/data/models/invoice_model.dart';

/// Aggregate invoice figures displayed in customer details.
///
/// This is derived from the current invoice stream, rather than cached values
/// on the customer document which may be stale.
class InvoiceCollectionStats {
  const InvoiceCollectionStats({
    required this.orderCount,
    required this.totalPurchases,
    required this.totalPaid,
    required this.totalRemaining,
    required this.unpaidInvoiceCount,
  });

  final int orderCount;
  final double totalPurchases;
  final double totalPaid;
  final double totalRemaining;
  final int unpaidInvoiceCount;

  factory InvoiceCollectionStats.fromInvoices(Iterable<InvoiceModel> source) {
    var orderCount = 0;
    var totalPurchases = 0.0;
    var totalPaid = 0.0;
    var totalRemaining = 0.0;
    var unpaidInvoiceCount = 0;

    for (final invoice in source) {
      orderCount++;
      totalPurchases += invoice.total;
      totalPaid += invoice.paidAmount;
      totalRemaining += invoice.remainingAmount;
      if (invoice.remainingAmount > 0) unpaidInvoiceCount++;
    }

    return InvoiceCollectionStats(
      orderCount: orderCount,
      totalPurchases: totalPurchases,
      totalPaid: totalPaid,
      totalRemaining: totalRemaining,
      unpaidInvoiceCount: unpaidInvoiceCount,
    );
  }
}
