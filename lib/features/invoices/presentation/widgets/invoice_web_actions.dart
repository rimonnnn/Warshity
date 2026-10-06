import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/check_invoice/data/invoice_actions_service.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/share_options_sheet.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';

class InvoiceWebActions {
  const InvoiceWebActions._();

  static InvoiceActionsService get _service =>
      InvoiceActionsService(getIt<InvoicePdfService>());

  static String formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date != null) return DateFormat('dd/MM/yyyy hh:mm a').format(date);

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);
    if (oldDate != null) return DateFormat('dd/MM/yyyy').format(oldDate);

    return value;
  }

  static void _error(BuildContext context, Object e) {
    if (!context.mounted) return;
    showAnimatedSnackDialog(
      context,
      message: e.toString().replaceFirst('Exception: ', ''),
      type: AnimatedSnackBarType.error,
    );
  }

  static Future<void> printInvoice(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    try {
      final bytes = await _service.generatePdf(
        invoice: invoice,
        locale: context.locale,
        labels: context.invoiceLabels,
      );
      await _service.printPdf(bytes);
    } catch (e) {
      _error(context, e);
    }
  }

  static Future<void> sharePdf(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    try {
      final bytes = await _service.generatePdf(
        invoice: invoice,
        locale: context.locale,
        labels: context.invoiceLabels,
      );
      await _service.sharePdf(
        pdfBytes: bytes,
        filename: '${invoice.invoiceId}.pdf',
      );
    } catch (e) {
      _error(context, e);
    }
  }

  static Future<void> shareImage(
    BuildContext context,
    InvoiceModel invoice,
    GlobalKey boundaryKey,
  ) async {
    try {
      await _service.exportImage(
        boundaryKey: boundaryKey,
        filename: '${invoice.invoiceId}.png',
      );
    } catch (e) {
      _error(context, e);
    }
  }

  static void openShareSheet(
    BuildContext context,
    InvoiceModel invoice,
    GlobalKey boundaryKey,
  ) {
    ShareOptionsSheet.show(
      context,
      onSharePdf: () => sharePdf(context, invoice),
      onShareImage: () => shareImage(context, invoice, boundaryKey),
    );
  }

  static Future<bool> deleteInvoice(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('Are you sure you want to delete this invoice?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return false;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await getIt<InvoiceRepository>().deleteInvoice(invoice.invoiceId!);

      if (!context.mounted) return true;
      Navigator.of(context, rootNavigator: true).pop();

      showAnimatedSnackDialog(
        context,
        message: 'invoice_deleted_successfully'.tr(),
        type: AnimatedSnackBarType.success,
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      Navigator.of(context, rootNavigator: true).pop();
      _error(context, e);
      return false;
    }
  }
}
