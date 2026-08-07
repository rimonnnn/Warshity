import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_status_badge.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.name,
    required this.phone,
    required this.amount,
    required this.hasDebt,
    this.avatar,
    this.onTap,
    this.backgroundColor,
    this.showDivider = false, this.padding,
  });

  final String name;
  final String phone;
  final String amount;
  final bool hasDebt;

  final Widget? avatar;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showDivider;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding ?? 16.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatar ??
                      Icon(
                        Icons.person,
                        color: context.colors.primary,
                        size: 28.sp,
                      ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16.sp,
                            color: context.colors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              phone,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      CustomerStatusBadge(
                        hasDebt: hasDebt,
                        amount: amount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: context.colors.outlineVariant,
          ),

          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.md),
              bottomRight: Radius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              child: Row(
                children: [
                  Text(
                    "details".tr(),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}