import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

/// Handles everything related to page sizing for the invoice PDF:
/// page format, margins, and the height estimation needed for
/// thermal printer formats (which require a fixed page height
/// up front, since the `pdf` package has no auto-sizing MultiPage).
class InvoicePdfLayout {
  const InvoicePdfLayout._();

  // =========================================================
  // Page
  // =========================================================

  static PdfPageFormat getPageFormat(
    InvoiceFormat format, {
    required InvoicePdfData data,
  }) {
    switch (format) {
      case InvoiceFormat.thermal58:
        return PdfPageFormat.roll57.copyWith(
          height: _calculateThermalHeight(
            data: data,
            format: InvoiceFormat.thermal58,
          ),
        );

      case InvoiceFormat.thermal80:
        return PdfPageFormat.roll80.copyWith(
          height: _calculateThermalHeight(
            data: data,
            format: InvoiceFormat.thermal80,
          ),
        );

      case InvoiceFormat.a4:
        return PdfPageFormat.a4;
    }
  }

  static double _calculateThermalHeight({
    required InvoicePdfData data,
    required InvoiceFormat format,
  }) {
    final is58 = format == InvoiceFormat.thermal58;

    /*
     * All values here are in mm.
     *
     * These are estimates based on the widgets used
     * in the invoice.
     */

    // Header:
    // logo + title + description + divider + invoice title
    // + invoice number + date
    const double headerHeight = 65.0;

    // Customer container
    const double customerHeight = 18.0;

    // Table header
    final double tableHeaderHeight = is58 ? 7.0 : 8.0;

    // One line item height
    final double oneLineItemHeight = is58 ? 7.5 : 9.0;

    // Totals section
    const double totalsHeight = 48.0;

    // Footer
    const double footerHeight = 12.0;

    // Spaces between sections
    const double spacingHeight = 40.0;

    // Calculate items height
    final double itemsHeight = data.items.fold<double>(0, (total, item) {
      final lines = _estimateProductNameLines(item.productName, format);

      return total + (oneLineItemHeight * lines);
    });

    final double contentHeight =
        headerHeight +
        customerHeight +
        tableHeaderHeight +
        itemsHeight +
        totalsHeight +
        footerHeight +
        spacingHeight;

    /*
     * Add a small safety buffer so the content doesn't
     * reach the very bottom of the thermal page.
     */
    const double safetyBuffer = 10.0;

    return (contentHeight + safetyBuffer) * PdfPageFormat.mm;
  }

  static int _estimateProductNameLines(
    String productName,
    InvoiceFormat format,
  ) {
    final is58 = format == InvoiceFormat.thermal58;

    /*
     * Approximate characters that can fit on one line.
     *
     * This isn't an exact PDF measurement, but it gives
     * us a much better page height than a fixed 500mm.
     */
    final int charactersPerLine = is58 ? 18 : 28;

    if (productName.isEmpty) {
      return 1;
    }

    final lines = (productName.length / charactersPerLine).ceil();

    // We use maxLines: 2 below.
    return lines.clamp(1, 2);
  }

  static pw.EdgeInsets getMargins(InvoiceFormat format) {
    switch (format) {
      case InvoiceFormat.thermal58:
        return const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6);

      case InvoiceFormat.thermal80:
        return const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8);

      case InvoiceFormat.a4:
        return const pw.EdgeInsets.all(30);
    }
  }

  // =========================================================
  // Spacing
  // =========================================================

  static pw.Widget spacing(InvoiceFormat format, {bool large = false}) {
    final isA4 = format == InvoiceFormat.a4;

    return pw.SizedBox(height: large ? (isA4 ? 25 : 12) : (isA4 ? 15 : 7));
  }
}