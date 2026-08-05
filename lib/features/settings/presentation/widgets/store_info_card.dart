import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({
    super.key,
    required this.children,
    this.title,
    this.onEdit,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  final List<Widget> children;

  final String? title;
  final VoidCallback? onEdit;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

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
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: context.colors.primary,
                  ),
                ),

                const Spacer(),

                Text(
                  title ?? "store_information",
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}