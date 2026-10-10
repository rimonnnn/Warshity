import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_developer_credit_widget.dart';

class InvoiceFooterWidget {
  const InvoiceFooterWidget._();

  static pw.Widget build({
    required Map<String, String> labels,
    required InvoiceFormat format,
  }) {
    final isA4 = format == InvoiceFormat.a4;

    final thankYouFontSize = isA4 ? 12.0 : 8.0;
    final brandFontSize = isA4 ? 8.0 : 6.0;

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Invoice footer
        pw.Container(
          width: double.infinity,
          margin: pw.EdgeInsets.only(top: isA4 ? 12 : 6),
          padding: pw.EdgeInsets.only(top: isA4 ? 10 : 5),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Separator
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Divider(color: PdfColors.grey300, thickness: 0.6),
                  ),
                  pw.SizedBox(width: isA4 ? 12 : 6),
                  pw.Container(
                    width: isA4 ? 5 : 3,
                    height: isA4 ? 5 : 3,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey400,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: isA4 ? 12 : 6),
                  pw.Expanded(
                    child: pw.Divider(color: PdfColors.grey300, thickness: 0.6),
                  ),
                ],
              ),

              pw.SizedBox(height: isA4 ? 12 : 5),

              // Thank-you message
              pw.Text(
                labels['thank_you'] ?? 'Thank you',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: thankYouFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),

              if (isA4) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  'WARSHITY',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: brandFontSize,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Developer credit
        InvoiceDeveloperCreditWidget.build(labels: labels, format: format),
      ],
    );
  }
}
