/// Pure accounting logic used when a customer makes a payment against invoices.
///
/// The caller is responsible for checking permissions and persisting the
/// returned balances inside a Firestore transaction.
class InvoicePaymentEntry {
  const InvoicePaymentEntry({
    required this.invoiceId,
    required this.createdAt,
    required this.total,
    required this.paidAmount,
  });

  final String invoiceId;
  final DateTime createdAt;
  final double total;
  final double paidAmount;
}

class InvoicePaymentAllocation {
  const InvoicePaymentAllocation({
    required this.invoiceId,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.appliedAmount,
  });

  final String invoiceId;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final double appliedAmount;
}

class InvoicePaymentAllocationResult {
  const InvoicePaymentAllocationResult({
    required this.allocations,
    required this.unallocatedPayment,
  });

  /// Results for invoices with a positive total, in oldest-first order.
  final List<InvoicePaymentAllocation> allocations;

  /// Portion of the payment that could not be allocated to invoice balances.
  /// This can represent manual debt not linked to invoices.
  final double unallocatedPayment;
}

class InvoicePaymentAllocator {
  const InvoicePaymentAllocator._();

  /// Allocates a payment against outstanding invoices, oldest first.
  ///
  /// `paidAmount` values supplied in [invoices] should already be normalized
  /// from legacy `paidAmount` / `remainingAmount` fields by the data source.
  static InvoicePaymentAllocationResult allocate({
    required Iterable<InvoicePaymentEntry> invoices,
    required double paymentAmount,
  }) {
    final ordered = invoices.where((invoice) => invoice.total > 0).toList()
      ..sort((a, b) {
        final dateOrder = a.createdAt.compareTo(b.createdAt);
        if (dateOrder != 0) return dateOrder;
        return a.invoiceId.compareTo(b.invoiceId);
      });

    var unallocated = paymentAmount > 0 ? paymentAmount : 0.0;
    final allocations = <InvoicePaymentAllocation>[];

    for (final invoice in ordered) {
      final total = invoice.total;
      final paidBeforePayment = invoice.paidAmount.clamp(0.0, total).toDouble();
      final outstanding = (total - paidBeforePayment).clamp(0.0, total).toDouble();

      var appliedAmount = 0.0;
      if (unallocated > 0.005 && outstanding > 0.005) {
        appliedAmount = unallocated < outstanding ? unallocated : outstanding;
        unallocated -= appliedAmount;
        if (unallocated.abs() < 0.005) unallocated = 0.0;
      }

      final paidAmount =
          (paidBeforePayment + appliedAmount).clamp(0.0, total).toDouble();
      final remainingAmount = (total - paidAmount).clamp(0.0, total).toDouble();

      allocations.add(
        InvoicePaymentAllocation(
          invoiceId: invoice.invoiceId,
          total: total,
          paidAmount: paidAmount,
          remainingAmount: remainingAmount,
          appliedAmount: appliedAmount,
        ),
      );
    }

    return InvoicePaymentAllocationResult(
      allocations: List<InvoicePaymentAllocation>.unmodifiable(allocations),
      unallocatedPayment: unallocated,
    );
  }

  /// Repairs historical records when a customer's current balance is less
  /// than the sum of their invoice outstanding amounts.
  ///
  /// Only the difference is treated as a previously-recorded invoice payment;
  /// if manual debt makes the customer balance higher, no historical payment
  /// is inferred from that excess.
  static InvoicePaymentAllocationResult reconcile({
    required Iterable<InvoicePaymentEntry> invoices,
    required double customerBalance,
  }) {
    final invoiceList = invoices.toList(growable: false);
    var totalOutstanding = 0.0;
    for (final invoice in invoiceList) {
      if (invoice.total <= 0) continue;
      final paid = invoice.paidAmount.clamp(0.0, invoice.total).toDouble();
      totalOutstanding +=
          (invoice.total - paid).clamp(0.0, invoice.total).toDouble();
    }

    final safeCustomerBalance = customerBalance < 0 ? 0.0 : customerBalance;
    final historicalPayment = totalOutstanding > safeCustomerBalance
        ? totalOutstanding - safeCustomerBalance
        : 0.0;

    return allocate(
      invoices: invoiceList,
      paymentAmount: historicalPayment,
    );
  }
}
