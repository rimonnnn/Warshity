import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_content.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_actions.dart';

class InvoiceReviewPanel extends StatefulWidget {
  const InvoiceReviewPanel({
    super.key,
    required this.invoice,
    required this.onClose,
    this.onDeleted,
    this.useInternalScroll = true,
  });

  final InvoiceModel invoice;
  final VoidCallback onClose;
  final VoidCallback? onDeleted;
  final bool useInternalScroll;

  @override
  State<InvoiceReviewPanel> createState() => _InvoiceReviewPanelState();
}

class _InvoiceReviewPanelState extends State<InvoiceReviewPanel> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _delete() async {
    final deleted = await InvoiceWebActions.deleteInvoice(
      context,
      widget.invoice,
    );
    if (deleted) widget.onDeleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'check_invoice'.tr(),
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (widget.useInternalScroll)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: RepaintBoundary(
                key: _boundaryKey,
                child: CheckInvoiceContent(invoice: widget.invoice),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: RepaintBoundary(
              key: _boundaryKey,
              child: CheckInvoiceContent(invoice: widget.invoice),
            ),
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'delete'.tr(),
                onPressed: _delete,
                style: IconButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
                ),
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      InvoiceWebActions.printInvoice(context, widget.invoice),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.print_outlined),
                  label: Text('print'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => InvoiceWebActions.openShareSheet(
                    context,
                    widget.invoice,
                    _boundaryKey,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.share_outlined),
                  label: Text('share'.tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
