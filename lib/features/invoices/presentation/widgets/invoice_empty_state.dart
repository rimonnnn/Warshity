import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoiceEmptyState extends StatelessWidget {
  const InvoiceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPadding.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80.sp, color: Colors.grey),
            SizedBox(height: 24.h),
            Text(
              'invoice_history',
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              'you_have_no_invoices_to_display'.tr(),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
