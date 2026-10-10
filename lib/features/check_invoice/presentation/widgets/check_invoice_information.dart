import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceInformation extends StatelessWidget {
  final InvoiceModel invoiceModel;

  const CheckInvoiceInformation({super.key, required this.invoiceModel});

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);

    if (oldDate != null) {
      return DateFormat('dd/MM/yyyy').format(oldDate);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    // كل صف (عنوان + قيمة) في Row واحد بدل عمودين منفصلين،
    // فالعنوان والقيمة دايمًا على نفس السطر حتى لو القيمة صغّرت (التاريخ)
    return Column(
      children: [
        _InfoRow(
          label: 'invoice_numer'.tr(),
          value: invoiceModel.invoiceId ?? '',
        ),

        const SizedBox(height: 8),

        _InfoRow(
          label: 'date'.tr(),
          value: _formatDate(invoiceModel.createdAt),
          fitToWidth: true,
        ),

        const SizedBox(height: 8),

        _InfoRow(label: 'customer'.tr(), value: invoiceModel.customerName),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.fitToWidth = false,
  });

  final String label;
  final String value;

  /// بيصغّر القيمة بدل ما تتقطع (للتاريخ)
  final bool fitToWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    final valueText = Text(
      value,
      maxLines: 1,
      overflow: fitToWidth ? TextOverflow.visible : TextOverflow.ellipsis,
      style: context.text.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Align(
            // AlignmentDirectional بدل Alignment.centerRight: القيمة على نهاية الصف في العربي والإنجليزي
            alignment: AlignmentDirectional.centerEnd,
            child: fitToWidth
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: valueText,
                  )
                : valueText,
          ),
        ),
      ],
    );
  }
}
