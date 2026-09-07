import 'dart:typed_data';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/amount_and_price_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_information.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/finally_price.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/paid_and_remaining.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/thanks_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/top_check_invoice_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/total_price.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceWeb extends StatefulWidget {
  const CheckInvoiceWeb({
    super.key,
    required this.invoice,
  });

  final InvoiceModel invoice;

  @override
  State<CheckInvoiceWeb> createState() => _CheckInvoiceWebState();
}

class _CheckInvoiceWebState extends State<CheckInvoiceWeb> {
  bool _invoiceSaved = false;

  Future<void> _saveInvoice() async {
    if (_invoiceSaved) return;

    final repository = getIt<InvoicesRepository>();

    await repository.createInvoice(widget.invoice);

    if (!mounted) return;

    setState(() {
      _invoiceSaved = true;
    });

    showAnimatedSnackDialog(
      context,
      message: 'invoice_created_successfully'.tr(),
      type: AnimatedSnackBarType.success,
    );
  }

  Future<Uint8List> _generatePdf(BuildContext context) async {
    final pdfService = getIt<InvoicePdfService>();

    final data = InvoicePdfData.fromInvoice(widget.invoice);

    return pdfService.generateInvoicePdf(
      data,
      context.locale,
      context.invoiceLabels,
    );
  }

  Future<void> _printInvoice(BuildContext context) async {
    try {
      final pdfBytes = await _generatePdf(context);

      final success = await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );

      if (success) {
        await _saveInvoice();
      }
    } catch (e) {
      debugPrint('Print invoice error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    try {
      final pdfBytes = await _generatePdf(context);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${widget.invoice.invoiceId}.pdf',
      );
    } catch (e) {
      debugPrint('Share invoice error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "check_invoice".tr(),
          style: context.text.headlineMedium,
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: context.colors.onPrimary,
              border: Border(
                right: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                _VerticalActionButton(
                  icon: Icons.print_outlined,
                  label: "print".tr(),
                  onTap: () => _printInvoice(context),
                ),

                const HeightSpace(16),

                _VerticalActionButton(
                  icon: Icons.share_outlined,
                  label: "share_pdf".tr(),
                  onTap: () => _shareInvoice(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 650,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppPadding.sm,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const HeightSpace(24),

                          const TopCheckInvoiceWidget(),

                          const HeightSpace(24),

                          Divider(
                            thickness: 1,
                            height: 20,
                            color: Colors.grey[400],
                          ),

                          const HeightSpace(16),

                          CheckInvoiceInformation(
                            invoiceModel: widget.invoice,
                          ),

                          const HeightSpace(24),

                          AmountAndPriceWidget(
                            items: widget.invoice.items,
                          ),

                          const HeightSpace(40),

                          Divider(
                            thickness: 1,
                            height: 20,
                            color: Colors.grey[400],
                          ),

                          const HeightSpace(16),

                          TotalPrice(
                            subtotal: widget.invoice.subtotal,
                            discount: widget.invoice.discount,
                          ),

                          const HeightSpace(16),

                          FinallyPrice(
                            total: widget.invoice.total,
                          ),

                          const HeightSpace(8),

                          PaidAndRemaining(
                            paidAmount: widget.invoice.paidAmount,
                            remainingAmount:
                                widget.invoice.remainingAmount,
                          ),

                          const HeightSpace(12),

                          const ThanksWidget(),

                          const HeightSpace(24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalActionButton extends StatelessWidget {
  const _VerticalActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: context.colors.primary,
            ),

            const HeightSpace(4),

            Text(
              label,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}