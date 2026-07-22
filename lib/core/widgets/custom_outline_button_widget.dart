import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/styling/app_colors.dart';

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
    final Color effectiveColor = borderColor ?? AppColors.primaryColor;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(width ?? 331.sp, height ?? 57.sp),
        side: BorderSide(color: effectiveColor, width: borderWidth ?? 1.5.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
      ),
      onPressed: onPress,
      child: Text(
        buttonText ?? "",
        style: TextStyle(
          color: textColor ?? effectiveColor,
          fontSize: fontSize ?? 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
