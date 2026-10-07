import 'package:easy_localization/easy_localization.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

enum InvoiceStatus { paid, partial, unpaid }

InvoiceStatus invoiceStatusOf(InvoiceModel invoice) {
  if (invoice.remainingAmount <= 0) return InvoiceStatus.paid;
  if (invoice.paidAmount > 0) return InvoiceStatus.partial;
  return InvoiceStatus.unpaid;
}

String money(double value) => '${value.toStringAsFixed(2)} ${'currency'.tr()}';
