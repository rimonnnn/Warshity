import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomOutlineButtonWidget extends StatelessWidget {
  final void Function()? onPress;
  final String? buttonText;
  final Color? borderColor;
  final Color? textColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? width;
  final double? height;
  final double? fontSize;

  const CustomOutlineButtonWidget({
    super.key,
    this.onPress,
    this.buttonText,
    this.borderColor,
    this.textColor,
    this.borderWidth,
    this.borderRadius,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = borderColor ?? context.colors.primary;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(width ?? 331.w, height ?? 57.h),
        side: BorderSide(color: effectiveColor, width: borderWidth ?? 1.5.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
      ),
      onPressed: onPress,
      child: Text(
        buttonText ?? "",
        style: context.text.titleMedium?.copyWith(
          color: textColor ?? effectiveColor,
          fontSize: fontSize ?? 16.sp,
        ),
      ),
    );
  }
}