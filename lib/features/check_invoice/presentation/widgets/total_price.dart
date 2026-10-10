import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({super.key, required this.subtotal, required this.discount});

  final double subtotal;
  final double discount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final currencyFormatter = NumberFormat.currency(
      locale: context.locale.toString(),
      symbol: context.locale.languageCode == 'ar' ? 'ج.م' : 'EGP',
      decimalDigits: 2,
    );

    final finalTotal = subtotal - discount;

    Widget priceRow({
      required String label,
      required String value,
      Color? valueColor,
      FontWeight? fontWeight,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: fontWeight ?? FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          priceRow(
            label: 'subtotal'.tr(),
            value: currencyFormatter.format(subtotal),
          ),

          const SizedBox(height: 16),

          // Discount
          priceRow(
            label: 'discount'.tr(),
            value: currencyFormatter.format(-discount),
            valueColor: colors.tertiary,
            fontWeight: FontWeight.w600,
          ),

          const SizedBox(height: 16),

          Divider(
            height: 1,
            thickness: 1,
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),

          const SizedBox(height: 16),

          // Final total
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'total_price'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  currencyFormatter.format(finalTotal),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
