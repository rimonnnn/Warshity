import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class EmptyProductsWidget extends StatelessWidget {
  const EmptyProductsWidget({
    super.key,
    this.text,
    this.icon,
  });

  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: context.colors.outlineVariant,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Icon(
                  icon ?? Icons.inventory_2_outlined,
                  color: context.colors.onSurfaceVariant,
                  size: 18.sp,
                ),

                SizedBox(width: 6.w),

                Text(
                  text ?? "end_of_products".tr(),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Divider(
              color: context.colors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}