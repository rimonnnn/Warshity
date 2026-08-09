import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "total_price".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 16),
            Text(
              "discount".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),

        Column(
          children: [
            Text(
              "1000",
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 16),
            Text(
              "0",
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),
      ],
    );
  }
}
