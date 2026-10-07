import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/theme/app_theme_extension.dart'; // عشان context.semantic

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
    final scheme = context.colors;
    final warning = sideIndicatorColor ?? context.semantic.warning;

    return Container(
      width: width,
      margin: margin,
      clipBehavior: Clip.antiAlias, // يقص المؤشر الجانبي على حواف الكارت
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainer,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        children: [
          // المؤشر الجانبي: على جهة الـ start (يمين في العربي، شمال في الإنجليزي)
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            child: Container(width: 4, color: warning),
          ),
          Column(
            children: [
              Padding(
                padding: padding ?? EdgeInsets.all(20.sp),
                child: Row(
                  children: [
                    Icon(icon, color: warning, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        title ?? "warning".tr(),
                        textAlign: TextAlign.start,
                        style: context.text.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h, color: scheme.outlineVariant),
              ...children,
            ],
          ),
        ],
      ),
    );
  }
}
