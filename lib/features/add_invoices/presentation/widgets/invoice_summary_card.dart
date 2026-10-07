import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double total;

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Card(
      margin: EdgeInsets.zero,
      // تحديد shape بيلغي حد الـ cardTheme، فبنرجعه
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(AppPadding.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'invoice_summary'.tr(),
              style: context.text.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const HeightSpace(12),
            _SummaryRow(label: 'subtotal'.tr(), value: _money(subtotal)),
            if (discount > 0) ...[
              const HeightSpace(8),
              _SummaryRow(
                label: 'discount'.tr(),
                value: '- ${_money(discount)}',
                valueColor: scheme.tertiary,
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.sm),
              child: Divider(height: 1, color: scheme.outlineVariant),
            ),
            _SummaryRow(
              label: 'final_total'.tr(),
              value: _money(total),
              isBold: true,
              labelStyle: context.text.titleSmall,
              valueStyle: context.text.titleLarge,
              labelColor: scheme.onSurface,
              valueColor: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelStyle,
    this.valueStyle,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final weight = isBold ? FontWeight.bold : FontWeight.normal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (labelStyle ?? context.text.bodyLarge)?.copyWith(
              fontWeight: weight,
              // الصفوف العادية ثانوية، وصف الإجمالي النهائي بلون النص الأساسي
              color: labelColor ?? scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: (valueStyle ?? context.text.bodyLarge)?.copyWith(
            fontWeight: weight,
            // الأرقام العادية بلون النص الأساسي بدل لون افتراضي غير محدد
            color: valueColor ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
