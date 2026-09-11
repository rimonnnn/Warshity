import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final void Function()? onPress;
  final String? buttonText;
  final Color? buttonColor;
  final Color? textColor;
  final double? borderRadius;
  final double? width;
  final double? height;
  final double? fontSize;
  final String? iconPath;
  final IconData? iconData;
  final double? iconSize;
  final Color? iconeColor;
  final bool? prefixicon;
  final bool? suffixicon;
  final double? buttonspacing;
  final bool isLoading;

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
    this.iconPath,
    this.iconData,
    this.iconeColor,
    this.iconSize,
    this.prefixicon,
    this.suffixicon,
    this.buttonspacing,
    this.isLoading = false,
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
      onPressed: isLoading ? null : onPress,
      child: isLoading
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5.w,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? context.colors.onPrimary,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  color: iconeColor ?? context.colors.onSurfaceVariant,
                  size: iconSize ?? 20,
                ),
                WidthSpace(12),
                Text(
                  buttonText ?? "",
                  style: context.text.titleMedium?.copyWith(
                    color: textColor ?? context.colors.onPrimary,
                    fontSize: fontSize ?? 16.sp,
                  ),
                ),
                SizedBox(width: buttonspacing ?? 12.w),
                if (suffixicon == true && iconPath != null)
                  Expanded(
                    child: Image.asset(
                      iconPath!,
                      width: 24.w,
                      height: 24.h,
                      color: textColor ?? context.colors.onPrimary,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
    );
  }
}
