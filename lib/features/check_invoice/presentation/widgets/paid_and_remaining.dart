import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class PaidAndRemaining extends StatelessWidget {
  const PaidAndRemaining({
    super.key,
    required this.paidAmount,
    required this.remainingAmount,
  });

  final double paidAmount;
  final double remainingAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.text;
    final successColor = context.appColors.success;

    final isPaid = remainingAmount <= 0;
    final remainingColor = isPaid ? successColor : colors.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Paid amount
        Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: successColor,
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Text(
                'the_paid'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Flexible(
              child: Text(
                paidAmount.toStringAsFixed(2),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Remaining amount
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: remainingColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: remainingColor.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(
                isPaid
                    ? Icons.check_circle_rounded
                    : Icons.pending_actions_rounded,
                size: 20,
                color: remainingColor,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'remaining'.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                child: Text(
                  remainingAmount.toStringAsFixed(2),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: remainingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
