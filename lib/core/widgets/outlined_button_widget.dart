import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';

class OutlinedButtonWidget extends StatelessWidget {
  const OutlinedButtonWidget({
    super.key,
    this.buttonText,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.iconPath,
    this.icon,
    this.iconWidth,
    this.iconHeight,
  });
  final String? buttonText;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final double? iconWidth;
  final double? iconHeight;
  final double? borderRadius;
  final String? iconPath;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText ?? "",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            SizedBox(width: 4),
            iconPath != null
                ? Image.asset(iconPath!, width: iconWidth, height: iconHeight)
                : icon!
          ],
        ),
      ),
    );
  }
}
