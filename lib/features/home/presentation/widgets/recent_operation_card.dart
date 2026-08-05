import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class RecentOperationCard extends StatelessWidget {
  const RecentOperationCard({
    super.key,
    required this.customerName,
    required this.time,
    required this.price,
    this.avatar,
    this.onTap,
    this.backgroundColor,
    this.avatarSize,
    this.widthbetween,
    this.horzontalPadding,
    this.verticalPadding,
    this.borderradius,
  });

  final String customerName;
  final String time;
  final String price;

  final Widget? avatar;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? avatarSize;
  final double? widthbetween;
  final double? horzontalPadding;
  final double? verticalPadding;
  final double? borderradius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horzontalPadding ?? 16.w,
          vertical: verticalPadding ?? 14.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(
            borderradius ?? AppRadius.lg,
          ),
          border: Border.all(
            color: context.colors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: const Color(0xffD8F0A7),
              child: avatar ??
                  Icon(
                    Icons.person_outline,
                    color: const Color(0xff5B7F22),
                    size: avatarSize ?? 22.sp,
                  ),
            ),

            SizedBox(width: widthbetween ?? 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                price,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}