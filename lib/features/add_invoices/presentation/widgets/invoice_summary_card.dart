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
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
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
              valueColor: context.colors.tertiary,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.sm),
            child: Divider(height: 1, color: context.colors.outlineVariant),
          ),
          _SummaryRow(
            label: 'final_total'.tr(),
            value: _money(total),
            isBold: true,
            labelStyle: context.text.titleSmall,
            valueStyle: context.text.titleMedium,
            valueColor: context.colors.primary,
          ),
        ],
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelStyle,
    this.valueStyle,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: (labelStyle ?? context.text.bodyLarge)?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      Text(
        value,
        style: (valueStyle ?? context.text.bodyLarge)?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: valueColor,
        ),
      ),
    ],
  );
}
