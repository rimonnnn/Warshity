import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({super.key, required this.subtotal, required this.discount});

  final double subtotal;
  final double discount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("total_price".tr(), style: context.text.bodyMedium),
            const SizedBox(height: 16),
            Text("discount".tr(), style: context.text.bodyLarge),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(subtotal.toStringAsFixed(2), style: context.text.bodyMedium),
            const SizedBox(height: 16),
            Text(
              "${discount.toStringAsFixed(0)} ج.م",
              style: context.text.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }
}
