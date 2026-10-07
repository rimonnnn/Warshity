import 'package:warshity/features/invoices/data/models/invoice_model.dart';

enum GlobalSearchResultType { client, product, invoice }

class GlobalSearchResult {
  final GlobalSearchResultType type;
  final String id;
  final String title;
  final String? subtitle;

  // Invoice data when the result is an invoice.
  final InvoiceModel? invoiceId;

  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.invoiceId,
  });
}
