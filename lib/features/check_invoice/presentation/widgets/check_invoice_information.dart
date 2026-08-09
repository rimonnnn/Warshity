import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CheckInvoiceInformation extends StatelessWidget {
  const CheckInvoiceInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "invoice_numer".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 8),
            Text(
              "date".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 8),
            Text(
              "customer".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "1".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 8),
            Text(
              "2o-9-2004".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 8),
            Text(
              "Rimon".tr(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),
      ],
    );
  }
}
