import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  final String title;
  final List<Widget> children;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}
