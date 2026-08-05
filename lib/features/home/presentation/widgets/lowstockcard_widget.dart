import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class LowStockCard extends StatelessWidget {
  final String? title;
  final IconData icon;
  final List<Widget> children;

  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? sideIndicatorColor;
  final BorderRadiusGeometry? borderRadius;

  const LowStockCard({
    super.key,
    required this.children,
    this.title,
    this.icon = Icons.warning_amber_rounded,
    this.width,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.sideIndicatorColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainerLow,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: AppRadius.md,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: sideIndicatorColor ?? Colors.orange,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: padding ?? EdgeInsets.all(20.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        title ?? "warning".tr(),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h),
              ...children,
            ],
          ),
        ],
      ),
    );
  }
}
