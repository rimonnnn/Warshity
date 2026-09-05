import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceFooterWidget {
  const InvoiceFooterWidget._();

  static pw.Widget build({
    required Map<String, String> labels,
    required InvoiceFormat format,
  }) {
    final isA4 = format == InvoiceFormat.a4;

    return pw.Column(
      children: [
        pw.Divider(),

        pw.SizedBox(height: 4),

        pw.Text(
          labels['thank_you'] ?? 'Thank you',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isA4 ? 12 : 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        if (isA4) ...[
          pw.SizedBox(height: 5),

          pw.Text(
            'WARSHITY',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ],
    );
  }
}