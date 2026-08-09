import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class AmountAndPriceWidget extends StatelessWidget {
  const AmountAndPriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFFFDCC5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "catagory".tr(),
                style: context.text.bodyLarge!.copyWith(
                  color: Color(0xFF6F4627),
                ),
              ),
              Text(
                "amount".tr(),
                style: context.text.bodyLarge!.copyWith(
                  color: Color(0xFF6F4627),
                ),
              ),
              Text(
                "the_price".tr(),
                style: context.text.bodyLarge!.copyWith(
                  color: Color(0xFF6F4627),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "the_wood".tr(),
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "glue".tr(),
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "400",
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "50",
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "800",
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "200",
                  style: context.text.bodyLarge!.copyWith(
                    color: Color(0xFF6F4627),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
