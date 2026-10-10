import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/check_invoice/data/invoice_actions_service.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_content.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/print_and_share_invoice.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/share_options_sheet.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceMobile extends StatefulWidget {
  const CheckInvoiceMobile({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  State<CheckInvoiceMobile> createState() => _CheckInvoiceMobileState();
}

class _CheckInvoiceMobileState extends State<CheckInvoiceMobile> {
  final GlobalKey _invoiceKey = GlobalKey();

  final _actions = InvoiceActionsService(getIt<InvoicePdfService>());

  bool _invoiceSaved = false;

  Future<void> _saveInvoiceIfNeeded() async {
    if (_invoiceSaved) return;

    await getIt<InvoicesRepository>().finalizeInvoice(widget.invoice);

    if (!mounted) return;

    setState(() => _invoiceSaved = true);

    showAnimatedSnackDialog(
      context,
      message: 'invoice_created_successfully'.tr(),
      type: AnimatedSnackBarType.success,
    );
  }

  void _showError(Object error) {
    debugPrint('Invoice action error: $error');
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _printInvoice() async {
    try {
      final pdfBytes = await _actions.generatePdf(
        invoice: widget.invoice,
        locale: context.locale,
        labels: context.invoiceLabels,
      );

      final printed = await _actions.printPdf(pdfBytes);

      if (printed) await _saveInvoiceIfNeeded();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _sharePdf() async {
    try {
      final pdfBytes = await _actions.generatePdf(
        invoice: widget.invoice,
        locale: context.locale,
        labels: context.invoiceLabels,
      );

      await _actions.sharePdf(
        pdfBytes: pdfBytes,
        filename: '${widget.invoice.invoiceId}.pdf',
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _shareImage() async {
    try {
      await _actions.exportImage(
        boundaryKey: _invoiceKey,
        filename: '${widget.invoice.invoiceId}.png',
      );
    } catch (e) {
      _showError(e);
    }
  }

  void _openShareSheet() {
    ShareOptionsSheet.show(
      context,
      onSharePdf: _sharePdf,
      onShareImage: _shareImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (_invoiceSaved) {
              context.pop();
              context.pop();
            } else {
              context.pop();
            }
          },
        ),
        // headlineMedium كبير على AppBar، titleMedium بالـ bold أنسب
        title: Text(
          'check_invoice'.tr(),
          style: context.text.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // SafeArea من تحت بس: الأزرار ماتلزقش في شريط الـ gestures
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              // بانر تأكيد بعد الحفظ: الـ snackbar بيختفي بعد ثواني،
              // والبانر بيفضل يوضح إن الفاتورة اتحفظت (بيعتمد على _invoiceSaved الموجودة)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _invoiceSaved
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.success.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: context.appColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'invoice_created_successfully'.tr(),
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.appColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    // surfaceContainer بحد، عشان "ورقة" الفاتورة تبان فوق الخلفية
                    // (كانت surface، نفس لون الصفحة، وبنصف radius صغير من AppPadding)
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: _invoiceKey,
                      child: CheckInvoiceContent(invoice: widget.invoice),
                    ),
                  ),
                ),
              ),

              HeightSpace(12),

              PrintAndShareInvoice(
                onShare: _openShareSheet,
                onPrint: _printInvoice,
              ),

              HeightSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
