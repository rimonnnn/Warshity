import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceHeaderWidget {
  const InvoiceHeaderWidget._();

  static pw.Widget build({
    required InvoicePdfData data,
    required Map<String, String> labels,
    required InvoiceFormat format,
    required pw.ImageProvider logo,
  }) {
    final isA4 = format == InvoiceFormat.a4;

    final logoSize = switch (format) {
      InvoiceFormat.thermal58 => 32.0,
      InvoiceFormat.thermal80 => 42.0,
      InvoiceFormat.a4 => 65.0,
    };

    final titleSize = switch (format) {
      InvoiceFormat.thermal58 => 14.0,
      InvoiceFormat.thermal80 => 17.0,
      InvoiceFormat.a4 => 26.0,
    };

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(
              logo,
              width: logoSize,
              height: logoSize,
              fit: pw.BoxFit.contain,
            ),

            pw.SizedBox(width: isA4 ? 12 : 6),

            pw.Text(
              'Masiter',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: titleSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: isA4 ? 14 : 7),

        pw.Divider(),

        pw.SizedBox(height: isA4 ? 8 : 4),

        pw.Text(
          labels['sales_invoice'] ?? 'فاتورة مبيعات',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isA4 ? 18 : 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          '${labels['invoice_no'] ?? 'Invoice #'} ${data.invoiceId}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: isA4 ? 11 : 7),
        ),

        pw.Text(
          data.createdAt,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: isA4 ? 11 : 7),
        ),
      ],
    );
  }
}