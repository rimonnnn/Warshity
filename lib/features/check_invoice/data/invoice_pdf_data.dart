import 'package:intl/intl.dart';

import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoicePdfData {
  final String invoiceId;
  final String createdAt;
  final String customerName;
  final List<InvoiceItemModel> items;

  final double subtotal;
  final double discount;
  final double discountAmount;
  final double total;
  final double paidAmount;
  final double remainingAmount;

  const InvoicePdfData({
    required this.invoiceId,
    required this.createdAt,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.discountAmount,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
  });

  factory InvoicePdfData.fromInvoice(InvoiceModel invoice) {
    final discountAmount = invoice.subtotal * invoice.discount / 100;

    final date = DateTime.tryParse(invoice.createdAt);

    final formattedDate = date != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(date)
        : invoice.createdAt;

    return InvoicePdfData(
      invoiceId: invoice.invoiceId!,
      createdAt: formattedDate,
      customerName: invoice.customerName,
      items: List.unmodifiable(invoice.items),
      subtotal: invoice.subtotal,
      discount: invoice.discount,
      discountAmount: discountAmount,
      total: invoice.total,
      paidAmount: invoice.paidAmount,
      remainingAmount: invoice.remainingAmount,
    );
  }
}
