import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerHeaderCard extends StatelessWidget {
  const CustomerHeaderCard({
    super.key,
    required this.name,
    required this.phone,
    this.avatar, this.padding, this.height, this.width, this.height1, this.width1,
  });

  final String name;
  final String phone;
  final Widget? avatar;
  final double? padding;
  final double? height;
  final double? width;
  final double? height1;
  final double? width1;



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding ?? 16.sp),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: width ?? 48.w,
            height: height ?? 48.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child:
                avatar ??
                Icon(Icons.person, color: context.colors.primary, size: 28.sp),
          ),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  phone,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          Container(
            width:width1 ?? 48.w,
            height: height1 ?? 48.h,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone, color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}
