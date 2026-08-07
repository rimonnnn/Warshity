import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingAddProductButton extends StatelessWidget {
  const FloatingAddProductButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Icon(
        icon ?? Icons.add,
        size: 28.sp,
      ),
    );
  }
}