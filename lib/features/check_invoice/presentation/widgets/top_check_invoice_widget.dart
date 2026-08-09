import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class TopCheckInvoiceWidget extends StatelessWidget {
  const TopCheckInvoiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(child: Image.asset(AppAssets.logo, width: 80, height: 80)),
        SizedBox(height: 12),
        Text(
          "bussnis_name".tr(),
          style: context.text.headlineSmall!.copyWith(color: Color(0xFF6F4627)),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "01220991666",
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            Text(
              "01220991666",
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),
      ],
    );
  }
}
