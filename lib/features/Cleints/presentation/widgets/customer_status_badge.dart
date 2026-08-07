import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerStatusBadge extends StatelessWidget {
  const CustomerStatusBadge({
    super.key,
    required this.hasDebt,
    required this.amount,
  });

  final bool hasDebt;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final color = hasDebt ? Colors.red : Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasDebt
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 16.sp,
            color: color,
          ),

          SizedBox(width: 6.w),

          Text(
            hasDebt
                ? "customer_debt".tr(args: [amount])
                : "customer_balance".tr(args: [amount]),
            style: context.text.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}