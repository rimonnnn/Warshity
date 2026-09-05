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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "the_paid".tr(),
              style: context.text.bodyLarge!.copyWith(
                color: const Color(0xFF6F4627),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "remaining".tr(),
              style: context.text.bodyLarge!.copyWith(
                color: const Color(0xFF6F4627),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              paidAmount.toStringAsFixed(2),
              style: context.text.bodyLarge!.copyWith(
                color: const Color(0xFF6F4627),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              remainingAmount.toStringAsFixed(2),
              style: context.text.bodyLarge!.copyWith(
                color: const Color(0xFF6F4627),
              ),
            ),
          ],
        ),
      ],
    );
  }
}