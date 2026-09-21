import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerDebtCard extends StatelessWidget {
  const CustomerDebtCard({
    super.key,
    required this.amount,
    this.onPayDebt,
  });

  final String amount;
  final VoidCallback? onPayDebt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          right: BorderSide(
            color: context.colors.error,
            width: 3.w,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            "current_debt".tr(),
            style: context.text.bodyLarge,
          ),

          SizedBox(height: 4.h),

          Text(
            amount,
            style: context.text.headlineSmall?.copyWith(
              color: context.colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPayDebt,
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                "pay_debt".tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}