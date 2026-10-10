import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

import 'invoice_popup_menu.dart';
import 'invoice_status_badge.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.paymentMethod,
    required this.itemCount,
    required this.totalPrice,
    required this.status,
    required this.onPrint,
    required this.onExport,
    required this.onExportImage,
    required this.onDelete,
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
  final VoidCallback onExportImage;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Card(
      color: context.colors.surfaceContainer,
      margin: EdgeInsets.symmetric(horizontal: AppPadding.md, vertical: 6.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppPadding.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '#$invoiceNumber',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InvoiceStatusBadge(status: status),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              customerName,
              style: context.text.bodyLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              date,
              style: context.text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),

            Divider(color: scheme.outlineVariant),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'item_count'.tr(),
                      style: context.text.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$itemCount ${'item_count'.tr()}',
                      style: context.text.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'total_price'.tr(),
                      style: context.text.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      totalPrice,
                      style: context.text.bodyLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // طريقة الدفع كـ pill زي الصورة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    paymentMethod,
                    style: context.text.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                InvoicePopupMenuItem(
                  onPrint: onPrint,
                  onExport: onExport,
                  onExportImage: onExportImage,
                  onDelete: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
