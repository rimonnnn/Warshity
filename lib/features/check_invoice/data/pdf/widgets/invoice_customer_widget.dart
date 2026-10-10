import 'package:pdf/pdf.dart';
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

    final fontSize = isA4 ? 11.0 : 7.0;
    final labelFontSize = isA4 ? 9.0 : 6.0;

    final horizontalPadding = isA4 ? 12.0 : 6.0;
    final verticalPadding = isA4 ? 10.0 : 5.0;

    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
        borderRadius: pw.BorderRadius.circular(isA4 ? 6 : 3),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Customer label
          pw.Container(
            padding: pw.EdgeInsets.symmetric(
              horizontal: isA4 ? 8 : 4,
              vertical: isA4 ? 5 : 2,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              labels['customer'] ?? 'Customer',
              style: pw.TextStyle(
                fontSize: labelFontSize,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),

          pw.SizedBox(width: isA4 ? 12 : 6),

          // Customer name
          pw.Expanded(
            child: pw.Text(
              data.customerName,
              textAlign: pw.TextAlign.end,
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
