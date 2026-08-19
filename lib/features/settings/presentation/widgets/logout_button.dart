import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  final VoidCallback onPressed;

  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,

        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                icon ?? Icons.logout_rounded,
              ),

        label: isLoading
            ? const SizedBox.shrink()
            : Text(
                title ?? "Logout",
              ),

        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.red,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}