import 'package:pdf/pdf.dart';
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
        ? 10.0
        : 8.5;

    final horizontalPadding = isA4 ? 10.0 : 3.0;
    final verticalPadding = isA4 ? 10.0 : 3.0;

    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: isA4
          ? pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
              borderRadius: pw.BorderRadius.circular(6),
            )
          : null,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Subtotal
          _row(
            labels['subtotal'] ?? 'Subtotal',
            data.subtotal.toStringAsFixed(2),
            fontSize: fontSize,
            labelColor: PdfColors.grey700,
            valueColor: PdfColors.grey800,
            verticalPadding: isA4 ? 5 : 2,
          ),

          // Discount
          if (data.discount > 0) ...[
            _row(
              labels['discount'] ?? 'Discount',
              '- ${data.discount.toStringAsFixed(2)}',
              fontSize: fontSize,
              labelColor: PdfColors.grey700,
              valueColor: PdfColors.grey700,
              verticalPadding: isA4 ? 5 : 2,
            ),
          ],

          // Separator before the final total
          _separator(isA4: isA4, verticalMargin: isA4 ? 8 : 4),

          // Final total
          _row(
            labels['total'] ?? 'Total',
            data.total.toStringAsFixed(2),
            fontSize: fontSize + 1.5,
            bold: true,
            horizontalPadding: isA4 ? 8 : 2,
            verticalPadding: isA4 ? 9 : 4,
            backgroundColor: isA4 ? PdfColors.grey200 : null,
            borderRadius: isA4 ? 4 : 0,
          ),

          pw.SizedBox(height: isA4 ? 8 : 4),

          // Paid amount
          _row(
            labels['paid'] ?? 'Paid',
            data.paidAmount.toStringAsFixed(2),
            fontSize: fontSize,
            labelColor: PdfColors.grey700,
            valueColor: PdfColors.grey800,
            verticalPadding: isA4 ? 5 : 2,
          ),

          // Remaining amount
          if (data.remainingAmount > 0) ...[
            _separator(isA4: isA4, verticalMargin: isA4 ? 5 : 3),

            _row(
              labels['remaining'] ?? 'Remaining',
              data.remainingAmount.toStringAsFixed(2),
              fontSize: fontSize + 1,
              bold: true,
              horizontalPadding: isA4 ? 8 : 2,
              verticalPadding: isA4 ? 8 : 4,
              backgroundColor: isA4 ? PdfColors.grey100 : null,
              borderRadius: isA4 ? 4 : 0,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _separator({
    required bool isA4,
    required double verticalMargin,
  }) {
    return pw.Container(
      width: double.infinity,
      height: isA4 ? 0.6 : 0.5,
      margin: pw.EdgeInsets.symmetric(vertical: verticalMargin),
      color: isA4 ? PdfColors.grey300 : PdfColors.grey500,
    );
  }

  static pw.Widget _row(
    String title,
    String value, {
    required double fontSize,
    bool bold = false,
    double horizontalPadding = 0,
    double verticalPadding = 2,
    PdfColor? labelColor,
    PdfColor? valueColor,
    PdfColor? backgroundColor,
    double borderRadius = 0,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: backgroundColor != null
          ? pw.BoxDecoration(
              color: backgroundColor,
              borderRadius: pw.BorderRadius.circular(borderRadius),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Label
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: labelColor ?? PdfColors.black,
              ),
            ),
          ),

          pw.SizedBox(width: 8),

          // Amount
          pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
