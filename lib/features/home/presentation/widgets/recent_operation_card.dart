import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/app_theme_extension.dart'; // context.semantic

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
    final scheme = context.colors;
    final radius = BorderRadius.circular(borderradius ?? AppRadius.lg);

    return Material(
      color: backgroundColor ?? scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: scheme.primary.withValues(alpha: 0.04),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horzontalPadding ?? 16.w,
            vertical: verticalPadding ?? 14.h,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: scheme.primaryContainer,
                child:
                    avatar ??
                    Icon(
                      Icons.person_outline,
                      color: scheme.primary,
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
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
                    color: context.semantic.success, // زي "$350.00" في الصورة
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
