import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

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
    final scheme = context.colors;

    // زر تدميري هادي (tonal): errorContainer بنص error،
    // بدل أحمر مليان بيصرخ في آخر الشاشة. الـ parameters لسه بتغلب لو اتبعتت.
    final bg = backgroundColor ?? scheme.errorContainer;
    final fg = foregroundColor ?? scheme.error;

    return SizedBox(
      width: width ?? double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,

        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            : Icon(icon ?? Icons.logout_rounded),

        label: isLoading
            ? const SizedBox.shrink()
            : Text(
                title ?? "logout".tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          // وقت الـ loading الزر يفضل بلونه بدل ما يتحول لرمادي
          disabledBackgroundColor: bg,
          disabledForegroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
