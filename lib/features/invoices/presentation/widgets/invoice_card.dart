import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'invoice_status_badge.dart';
import 'invoice_popup_menu.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.paymentMethod,
    required this.itemCount,
    required this.totalPrice,
    required this.status, required this.onPrint, required this.onExport, required this.onDelete,
  });

  final String invoiceNumber;
  final String customerName;
  final String date;
  final String paymentMethod;
  final int itemCount;
  final String totalPrice;
  final String status;
    final VoidCallback onPrint;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppPadding.md, vertical: 6.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppPadding.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$invoiceNumber',
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                InvoiceStatusBadge(status: status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              customerName,
              style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              date,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'item_count'.tr(),
                      style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    Text('$itemCount Items', style: context.text.bodyMedium),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'total_price'.tr(),
                      style: context.text.labelLarge?.copyWith(color: context.colors.primary),
                    ),
                    Text(
                      totalPrice,
                      style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(paymentMethod),
                const SizedBox(width: 8),
                 InvoicePopupMenuItem(
                  onDelete: onDelete,
                  onExport: onExport,
                  onPrint: onPrint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}