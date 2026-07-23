import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: iconColor ?? context.colors.onSurface,
        ),
      ),
    );
  }
}