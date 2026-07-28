import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';

class OutlinedButtonWidget extends StatelessWidget {
  const OutlinedButtonWidget({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.iconPath,
  });
  final String buttonText;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final double? borderRadius;
  final String? iconPath;
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
            if (iconPath != null)
              Image.asset(
                iconPath!,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            SizedBox(width: 8),
            Text(buttonText, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
