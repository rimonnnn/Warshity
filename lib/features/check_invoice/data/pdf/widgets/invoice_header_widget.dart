import 'package:pdf/pdf.dart';
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
      InvoiceFormat.thermal58 => 28.0,
      InvoiceFormat.thermal80 => 36.0,
      InvoiceFormat.a4 => 58.0,
    };

    final titleSize = switch (format) {
      InvoiceFormat.thermal58 => 14.0,
      InvoiceFormat.thermal80 => 17.0,
      InvoiceFormat.a4 => 24.0,
    };

    final invoiceTitleSize = isA4 ? 17.0 : 11.0;
    final invoiceNumberSize = isA4 ? 11.0 : 7.5;
    final dateSize = isA4 ? 9.0 : 7.0;

    final sectionSpacing = isA4 ? 14.0 : 7.0;

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // App branding
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
                color: PdfColors.black,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: sectionSpacing),

        // Separator between branding and invoice information
        pw.Container(
          width: double.infinity,
          height: isA4 ? 0.8 : 0.6,
          color: PdfColors.grey500,
        ),

        pw.SizedBox(height: isA4 ? 12 : 6),

        // Invoice information
        pw.Container(
          width: double.infinity,
          padding: pw.EdgeInsets.symmetric(
            horizontal: isA4 ? 12 : 5,
            vertical: isA4 ? 12 : 6,
          ),
          decoration: pw.BoxDecoration(
            color: isA4 ? PdfColors.grey100 : PdfColors.white,
            borderRadius: pw.BorderRadius.circular(isA4 ? 6 : 3),
          ),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Invoice title
              pw.Text(
                labels['sales_invoice'] ?? 'Sales Invoice',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: invoiceTitleSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),

              pw.SizedBox(height: isA4 ? 8 : 4),

              // Invoice number
              pw.Text(
                '${labels['invoice_no'] ?? 'Invoice #'} ${data.invoiceId}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: invoiceNumberSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),

              pw.SizedBox(height: isA4 ? 4 : 2),

              // Creation date
              pw.Text(
                data.createdAt,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: dateSize,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: isA4 ? 10 : 4),
      ],
    );
  }
}
