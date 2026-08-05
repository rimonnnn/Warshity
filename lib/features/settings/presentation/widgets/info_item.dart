import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.showDivider = true,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        value,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: context.colors.primary, size: 20.sp),
                ),
              ],
            ),
          ),

          if (showDivider)
            Divider(height: 1, color: context.colors.outlineVariant),
        ],
      ),
    );
  }
}
