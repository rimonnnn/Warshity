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

    final cellPadding = is58 ? 2.0 : 3.0;

    return pw.Table(
      border: isA4
          ? pw.TableBorder.all(width: 0.5)
          : pw.TableBorder(horizontalInside: pw.BorderSide(width: 0.4)),

      columnWidths: is58
          ? {
              0: const pw.FlexColumnWidth(3.5),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(1.8),
            }
          : {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },

      children: [
        // Header
        pw.TableRow(
          decoration: isA4
              ? const pw.BoxDecoration(color: PdfColors.grey300)
              : null,
          children: [
            _cell(
              labels['item'] ?? 'Item',
              fontSize: fontSize,
              padding: cellPadding,
              bold: true,
            ),
            _cell(
              labels['qty'] ?? 'Qty',
              fontSize: fontSize,
              padding: cellPadding,
              bold: true,
              textAlign: pw.TextAlign.center,
            ),
            _cell(
              labels['price'] ?? 'Price',
              fontSize: fontSize,
              padding: cellPadding,
              bold: true,
              textAlign: pw.TextAlign.center,
            ),
            _cell(
              labels['total'] ?? 'Total',
              fontSize: fontSize,
              padding: cellPadding,
              bold: true,
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),

        // Items
        ...data.items.map(
          (item) => pw.TableRow(
            children: [
              _cell(
                item.productName,
                fontSize: fontSize,
                padding: cellPadding,
                maxLines: is58 ? 2 : 3,
              ),

              _cell(
                item.quantity.toString(),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.center,
              ),

              _cell(
                item.price.toStringAsFixed(2),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.center,
              ),

              _cell(
                (item.price * item.quantity).toStringAsFixed(2),
                fontSize: fontSize,
                padding: cellPadding,
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    required double fontSize,
    required double padding,
    bool bold = false,
    pw.TextAlign? textAlign,
    int maxLines = 2,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(padding),
      child: pw.Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
