import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:pdf/widgets.dart' as pw;
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_pdf_assets.dart';
import 'package:warshity/features/check_invoice/data/pdf/invoice_pdf_layout.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_customer_widget.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_footer_widget.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_header_widget.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_items_table_widget.dart';
import 'package:warshity/features/check_invoice/data/pdf/widgets/invoice_totals_widget.dart';

export 'package:warshity/features/check_invoice/data/pdf/invoice_format.dart';

/// Builds the invoice PDF document by wiring together layout,
/// assets, and the individual section widgets.
class InvoicePdfService {
  Future<Uint8List> generateInvoicePdf(
    InvoicePdfData data,
    Locale locale,
    Map<String, String> labels, {
    InvoiceFormat format = InvoiceFormat.thermal80,
  }) async {
    final isArabic = locale.languageCode == 'ar';

    final pdf = pw.Document();

    final regularFont = await InvoicePdfAssets.loadFont(isArabic, bold: false);
    final boldFont = await InvoicePdfAssets.loadFont(isArabic, bold: true);
    final logo = await InvoicePdfAssets.loadLogo();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: InvoicePdfLayout.getPageFormat(format, data: data),
        margin: InvoicePdfLayout.getMargins(format),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (_) => [
          pw.Directionality(
            textDirection: isArabic
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: _buildInvoice(
              data: data,
              labels: labels,
              format: format,
              logo: logo,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildInvoice({
    required InvoicePdfData data,
    required Map<String, String> labels,
    required InvoiceFormat format,
    required pw.ImageProvider logo,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        InvoiceHeaderWidget.build(
          data: data,
          labels: labels,
          format: format,
          logo: logo,
        ),

        InvoicePdfLayout.spacing(format),

        InvoiceCustomerWidget.build(data: data, labels: labels, format: format),

        InvoicePdfLayout.spacing(format),

        InvoiceItemsTableWidget.build(data: data, labels: labels, format: format),

        InvoicePdfLayout.spacing(format),

        InvoiceTotalsWidget.build(data: data, labels: labels, format: format),

        InvoicePdfLayout.spacing(format, large: true),

        InvoiceFooterWidget.build(labels: labels, format: format),
      ],
    );
  }
}