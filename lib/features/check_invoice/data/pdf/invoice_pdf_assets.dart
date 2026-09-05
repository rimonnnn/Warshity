import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Loads the fonts and logo image used when rendering the invoice PDF.
class InvoicePdfAssets {
  const InvoicePdfAssets._();

  static Future<pw.ImageProvider> loadLogo() async {
    final data = await rootBundle.load('assets/images/latest_logo.png');

    return pw.MemoryImage(data.buffer.asUint8List());
  }

  static Future<pw.Font> loadFont(bool isArabic, {required bool bold}) async {
    final path = isArabic
        ? 'assets/fonts/NotoSansArabic-${bold ? 'Bold' : 'Regular'}.ttf'
        : 'assets/fonts/BeVietnamPro-${bold ? 'Bold' : 'Regular'}.ttf';

    final data = await rootBundle.load(path);

    return pw.Font.ttf(data);
  }
}