import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_content.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

import 'web_form_widgets.dart';
import 'web_misc_widgets.dart';

class WebInvoicePreview extends StatelessWidget {
  const WebInvoicePreview({
    super.key,
    required this.invoice,
    required this.previewKey,
    required this.canUseActions,
    required this.invoiceSaved,
    required this.onShare,
    required this.onPrint,
  });

  final InvoiceModel invoice;
  final GlobalKey previewKey;
  final bool canUseActions;
  final bool invoiceSaved;
  final VoidCallback onShare;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebSectionCard(
          title: 'check_invoice'.tr(),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: previewKey,
                child: CheckInvoiceContent(invoice: invoice),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: !canUseActions,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: canUseActions ? 1 : 0.5,
            child: WebPrintShareButtons(
              onShare: onShare,
              onPrint: onPrint,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (invoiceSaved)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'invoice_created_successfully'.tr(),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
