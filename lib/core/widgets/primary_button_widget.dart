import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final void Function()? onPress;
  final String? buttonText;
  final Color? buttonColor;
  final Color? textColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final double? fontSize;

  const PrimaryButtonWidget({
    super.key,
    this.onPress,
    this.buttonText,
    this.buttonColor,
    this.borderRadius,
    this.width,
    this.height,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? context.colors.primary,
        fixedSize: Size(width ?? 331.w, height ?? 57.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
      ),
      onPressed: onPress,
      child: Text(
        buttonText ?? "",
        style: context.text.titleMedium?.copyWith(
          color: textColor ?? context.colors.onPrimary,
          fontSize: fontSize ?? 16.sp,
        ),
      ),
    );
  }
}