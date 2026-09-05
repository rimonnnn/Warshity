import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceInformation extends StatelessWidget {
  final InvoiceModel invoiceModel;
  const CheckInvoiceInformation({super.key, required this.invoiceModel});

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
              invoiceModel.invoiceId.toString(),

              style: context.text.bodyLarge!.copyWith(
                color: Color(0xFF6F4627),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
            Text(
              maxLines: 1,
              overflow: TextOverflow.fade,
              invoiceModel.createdAt.toString(),
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
            SizedBox(height: 8),
            Text(
              invoiceModel.customerName,
              style: context.text.bodyLarge!.copyWith(color: Color(0xFF6F4627)),
            ),
          ],
        ),
      ],
    );
  }
}
