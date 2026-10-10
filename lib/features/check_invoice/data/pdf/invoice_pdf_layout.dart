import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

/// Handles everything related to page sizing for the invoice PDF:
/// page format, margins, and height estimation for thermal printers.
///
/// Thermal printers require a calculated page height in advance.
/// The estimated height is calculated in millimeters and converted
/// to PDF points before being assigned to the page format.
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

  // =========================================================
  // Thermal Height Estimation
  // All estimated heights are in millimeters.
  // The final height is converted to PDF points.
  // =========================================================

  static double _calculateThermalHeight({
    required InvoicePdfData data,
    required InvoiceFormat format,
  }) {
    final is58 = format == InvoiceFormat.thermal58;

    // Header:
    // Logo, application name, divider, invoice title,
    // invoice number, and creation date.
    const double headerHeight = 65.0;

    // Customer information.
    const double customerHeight = 18.0;

    // Table header.
    final double tableHeaderHeight = is58 ? 7.0 : 8.0;

    // Estimated height for one line of a product name.
    final double oneLineItemHeight = is58 ? 7.5 : 9.0;

    // Totals section.
    const double totalsHeight = 48.0;

    // Invoice footer, including the thank-you message.
    const double footerHeight = 12.0;

    // Developer credit:
    // Developer names and contact numbers.
    final double developerCreditHeight = is58 ? 9.0 : 10.0;

    // Estimated spacing between invoice sections.
    const double spacingHeight = 40.0;

    // Calculate the height required by all product rows.
    final double itemsHeight = data.items.fold<double>(0, (total, item) {
      final lines = _estimateProductNameLines(item.productName, format);

      return total + (oneLineItemHeight * lines);
    });

    // Calculate the estimated total content height.
    final double contentHeight =
        headerHeight +
        customerHeight +
        tableHeaderHeight +
        itemsHeight +
        totalsHeight +
        footerHeight +
        developerCreditHeight +
        spacingHeight;

    // Additional safety margin to reduce the risk of overflow.
    const double safetyBuffer = 10.0;

    // Convert millimeters to PDF points.
    return (contentHeight + safetyBuffer) * PdfPageFormat.mm;
  }

  // =========================================================
  // Product Name Height Estimation
  // =========================================================

  static int _estimateProductNameLines(
    String productName,
    InvoiceFormat format,
  ) {
    final is58 = format == InvoiceFormat.thermal58;

    // Approximate characters per line.
    final int charactersPerLine = is58 ? 18 : 28;

    // Must match InvoiceItemsTableWidget.
    final int maxLines = is58 ? 2 : 3;

    if (productName.trim().isEmpty) {
      return 1;
    }

    final int estimatedLines = (productName.length / charactersPerLine).ceil();

    return estimatedLines.clamp(1, maxLines).toInt();
  }

  // =========================================================
  // Margins
  // =========================================================

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

    return pw.SizedBox(
      height: large ? (isA4 ? 25.0 : 12.0) : (isA4 ? 15.0 : 7.0),
    );
  }
}
