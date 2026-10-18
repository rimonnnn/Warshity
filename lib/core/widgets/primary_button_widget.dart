import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/animated_loading_indicator.dart';
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isLoading
            ? AnimatedLoadingIndicator(
                key: const ValueKey('loading'),
                color: textColor ?? context.colors.onPrimary,
                size: ((height ?? 57.h) * 0.1).clamp(4.0, 6.0),
              )
            : Row(
                key: const ValueKey('content'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconData != null) ...[
                    Icon(
                      iconData,
                      color: iconeColor ?? context.colors.onPrimary,
                      size: iconSize ?? 20,
                    ),
                    WidthSpace(buttonspacing ?? 12),
                  ],
                  Flexible(
                    child: Text(
                      buttonText ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        color: textColor ?? context.colors.onPrimary,
                        fontSize: fontSize ?? 16.sp,
                      ),
                    ),
                  ),
                  if (suffixicon == true && iconPath != null) ...[
                    SizedBox(width: buttonspacing ?? 12.w),
                    Image.asset(
                      iconPath!,
                      width: 24.w,
                      height: 24.h,
                      color: textColor ?? context.colors.onPrimary,
                      fit: BoxFit.contain,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
