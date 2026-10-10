import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

class InvoiceItemsTableWidget {
  const InvoiceItemsTableWidget._();

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
        : 8.0;

    final headerFontSize = isA4 ? 9.5 : fontSize;

    final cellPadding = is58
        ? 2.0
        : isA4
        ? 5.0
        : 3.0;

    final borderColor = PdfColors.grey300;

    return pw.Table(
      border: isA4
          ? pw.TableBorder(
              top: const pw.BorderSide(color: PdfColors.grey400, width: 0.6),
              bottom: const pw.BorderSide(color: PdfColors.grey400, width: 0.6),
              left: const pw.BorderSide(color: PdfColors.grey400, width: 0.6),
              right: const pw.BorderSide(color: PdfColors.grey400, width: 0.6),
              horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
              verticalInside: pw.BorderSide(color: borderColor, width: 0.4),
            )
          : pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey400,
                width: is58 ? 0.35 : 0.45,
              ),
            ),

      columnWidths: is58
          ? {
              0: const pw.FlexColumnWidth(3.3),
              1: const pw.FlexColumnWidth(0.9),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(2.0),
            }
          : {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },

      children: [
        // Table header
        pw.TableRow(
          decoration: isA4
              ? const pw.BoxDecoration(color: PdfColors.grey200)
              : null,
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            _cell(
              labels['item'] ?? 'Item',
              fontSize: headerFontSize,
              padding: cellPadding,
              bold: true,
              color: PdfColors.grey800,
              textAlign: pw.TextAlign.left,
            ),
            _cell(
              labels['qty'] ?? 'Qty',
              fontSize: headerFontSize,
              padding: cellPadding,
              bold: true,
              color: PdfColors.grey800,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
            ),
            _cell(
              labels['price'] ?? 'Price',
              fontSize: headerFontSize,
              padding: cellPadding,
              bold: true,
              color: PdfColors.grey800,
              textAlign: pw.TextAlign.right,
              maxLines: 1,
            ),
            _cell(
              labels['total'] ?? 'Total',
              fontSize: headerFontSize,
              padding: cellPadding,
              bold: true,
              color: PdfColors.grey800,
              textAlign: pw.TextAlign.right,
              maxLines: 1,
            ),
          ],
        ),

        // Product rows
        ...data.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return pw.TableRow(
            decoration: isA4 && index.isOdd
                ? const pw.BoxDecoration(color: PdfColors.grey100)
                : null,
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              // Product name
              _cell(
                item.productName,
                fontSize: fontSize,
                padding: cellPadding,
                maxLines: is58 ? 2 : 3,
                textAlign: pw.TextAlign.left,
              ),

              // Quantity
              _cell(
                item.quantity.toString(),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.center,
                maxLines: 1,
              ),

              // Unit price
              _cell(
                item.price.toStringAsFixed(2),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.right,
                maxLines: 1,
              ),

              // Line total
              _cell(
                (item.price * item.quantity).toStringAsFixed(2),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.right,
                bold: isA4,
                maxLines: 1,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    required double fontSize,
    required double padding,
    bool bold = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign textAlign = pw.TextAlign.left,
    int maxLines = 2,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      child: pw.Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
