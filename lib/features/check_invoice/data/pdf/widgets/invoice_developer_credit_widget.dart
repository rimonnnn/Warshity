import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceDeveloperCreditWidget {
  const InvoiceDeveloperCreditWidget._();

  static const String _phone = '01206174130';
  static const String _phone1 = '01279914491';

  static pw.Widget build({
    required Map<String, String> labels,
    required InvoiceFormat format,
  }) {
    final is58 = format == InvoiceFormat.thermal58;
    final isA4 = format == InvoiceFormat.a4;

    final labelFontSize = is58
        ? 5.0
        : isA4
            ? 8.0
            : 6.0;

    final namesFontSize = is58
        ? 6.0
        : isA4
            ? 9.0
            : 7.0;

    final phoneFontSize = is58
        ? 5.5
        : isA4
            ? 8.0
            : 6.5;

    return pw.Container(
      width: double.infinity,
      margin: pw.EdgeInsets.only(top: isA4 ? 12 : 5),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Developed by
          pw.Text(
            labels['developed_by'] ?? 'Developed by',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: labelFontSize,
              color: PdfColors.grey600,
            ),
          ),

          pw.SizedBox(height: isA4 ? 3 : 2),

          // Developer names
          pw.Text(
            labels['developer_names'] ?? 'Developer Team',
            textAlign: pw.TextAlign.center,
            maxLines: 2,
            style: pw.TextStyle(
              fontSize: namesFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),

          pw.SizedBox(height: isA4 ? 5 : 3),

          // Contact numbers: force LTR so digits remain in the correct order.
          pw.Directionality(
            textDirection: pw.TextDirection.ltr,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  _phone,
                  style: pw.TextStyle(
                    fontSize: phoneFontSize,
                    color: PdfColors.grey700,
                  ),
                ),

                pw.SizedBox(width: isA4 ? 14 : 8),

                pw.Text(
                  _phone1,
                  style: pw.TextStyle(
                    fontSize: phoneFontSize,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}