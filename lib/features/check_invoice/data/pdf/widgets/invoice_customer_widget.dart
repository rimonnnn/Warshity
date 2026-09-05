import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceCustomerWidget {
  const InvoiceCustomerWidget._();

  static pw.Widget build({
    required InvoicePdfData data,
    required Map<String, String> labels,
    required InvoiceFormat format,
  }) {
    final isA4 = format == InvoiceFormat.a4;

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(
        vertical: isA4 ? 8 : 4,
        horizontal: isA4 ? 10 : 5,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            labels['customer'] ?? 'Customer',
            style: pw.TextStyle(
              fontSize: isA4 ? 11 : 7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(width: 6),

          pw.Expanded(
            child: pw.Text(
              data.customerName,
              textAlign: pw.TextAlign.end,
              maxLines: 1,
              style: pw.TextStyle(fontSize: isA4 ? 11 : 7),
            ),
          ),
        ],
      ),
    );
  }
}