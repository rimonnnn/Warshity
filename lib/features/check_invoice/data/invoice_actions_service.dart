import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

/// Handles PDF generation, printing, sharing (as PDF or image),
/// and repaint-boundary image capture for an invoice.
///
/// Kept free of BuildContext-dependent UI logic (snackbars, navigation)
/// so it can be unit-tested and reused independently of the widget tree.
class InvoiceActionsService {
  InvoiceActionsService(this._pdfService);

  final InvoicePdfService _pdfService;

  Future<Uint8List> generatePdf({
    required InvoiceModel invoice,
    required ui.Locale locale,
    required Map<String, String> labels,
  }) {
    final data = InvoicePdfData.fromInvoice(invoice);
    return _pdfService.generateInvoicePdf(data, locale, labels);
  }

  Future<bool> printPdf(Uint8List pdfBytes) {
    return Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String filename,
  }) {
    return Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  /// Captures the widget behind [boundaryKey] as a PNG.
  /// Throws if the boundary isn't mounted/ready yet.
  Future<Uint8List> captureAsImage(GlobalKey boundaryKey) async {
    final renderObject = boundaryKey.currentContext?.findRenderObject();

    if (renderObject is! RenderRepaintBoundary) {
      throw Exception('Invoice boundary is not ready');
    }

    final image = await renderObject.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert invoice to PNG');
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> shareImage({
    required Uint8List imageBytes,
    required String filename,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(imageBytes, mimeType: 'image/png', name: filename),
        ],
      ),
    );
  }
  Future<void> exportImage({
  required GlobalKey boundaryKey,
  required String filename,
}) async {
  final imageBytes = await captureAsImage(boundaryKey);

  await shareImage(
    imageBytes: imageBytes,
    filename: filename,
  );
}
}