import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SecurityCard extends StatelessWidget {
  const SecurityCard({
    super.key,
    required this.children,
    this.title,
    this.backgroundColor,
    this.borderRadius,
  });

  final List<Widget> children;

  final String? title;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppRadius.lg,
        ),
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
            padding: EdgeInsets.all(16.sp),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                title ?? "security",
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