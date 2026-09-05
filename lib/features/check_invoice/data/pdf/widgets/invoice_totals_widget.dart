import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceTotalsWidget {
  const InvoiceTotalsWidget._();

  static pw.Widget build({
    required InvoicePdfData data,
    required Map<String, String> labels,
    required InvoiceFormat format,
  }) {
    final is58 = format == InvoiceFormat.thermal58;
    final isA4 = format == InvoiceFormat.a4;

    final fontSize = is58
        ? 7.0
        : isA4
        ? 11.0
        : 9.0;

    return pw.Container(
      padding: isA4
          ? const pw.EdgeInsets.all(10)
          : const pw.EdgeInsets.symmetric(vertical: 3),
      decoration: isA4
          ? pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
              borderRadius: pw.BorderRadius.circular(5),
            )
          : null,
      child: pw.Column(
        children: [
          _row(
            labels['subtotal'] ?? 'Subtotal',
            data.subtotal,
            fontSize: fontSize,
          ),

          if (data.discount > 0)
            _row(
              labels['discount'] ?? 'Discount',
              data.discount,
              fontSize: fontSize,
            ),

          pw.Divider(),

          _row(
            labels['total'] ?? 'Total',
            data.total,
            fontSize: fontSize + 1,
            bold: true,
          ),

          _row(labels['paid'] ?? 'Paid', data.paidAmount, fontSize: fontSize),

          if (data.remainingAmount > 0)
            _row(
              labels['remaining'] ?? 'Remaining',
              data.remainingAmount,
              fontSize: fontSize + 1,
              bold: true,
            ),
        ],
      ),
    );
  }

  static pw.Widget _row(
    String title,
    double value, {
    required double fontSize,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value.toStringAsFixed(2),
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}