import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
  });

  final InvoiceModel invoice;
  final VoidCallback? onTap;

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);

    if (oldDate != null) {
      return DateFormat('dd/MM/yyyy').format(oldDate);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = invoice.remainingAmount <= 0;

    final statusColor = isPaid
        ? Colors.green
        : context.colors.error;

    final paymentMethod = isPaid
        ? 'paid'.tr()
        : 'unpaid'.tr();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(
                  AppRadius.sm,
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: statusColor,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    _formatDate(invoice.createdAt),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.total.toStringAsFixed(2),
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),

                SizedBox(height: 4.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    paymentMethod,
                    style: context.text.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}