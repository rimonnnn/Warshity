import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.onTap,
    this.title,
    this.icon,
    this.padding,
    this.heightspace,
    this.iconSize,
    this.value,
  });
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final String? title;
  final IconData? icon;
  final double? padding;
  final double? heightspace;
  final double? iconSize;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? 200.w,
        height: height ?? 90.h,
        decoration: BoxDecoration(
          color: color ?? context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding ?? 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title ?? "total_clients".tr(),
                    style: context.text.bodyMedium,
                  ),
                  Spacer(),
                  Icon(
                    icon ?? Icons.people,
                    size: iconSize ?? 16.sp,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
              HeightSpace(heightspace ?? 12.h),
              Text(
                value ?? "0",
                style: context.text.titleLarge?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
