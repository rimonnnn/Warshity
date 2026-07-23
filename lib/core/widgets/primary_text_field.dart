import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class PrimaryTextField extends StatelessWidget {
  final String? hintText;
  final double? width;
  final bool? isPassword;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PrimaryTextField({
    super.key,
    this.hintText,
    this.isPassword,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.width,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350.w,
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        cursorColor: context.colors.primary,
        obscureText: isPassword ?? false,
        style: context.text.bodyLarge?.copyWith(
          color: context.colors.onSurface,
        ),
        decoration: InputDecoration(
          fillColor: context.colors.surface,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 12.w,
          ),
          hintText: hintText ?? "",
          hintStyle: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: context.colors.outlineVariant,
              width: 1.w,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: context.colors.outlineVariant,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: context.colors.primary, width: 1.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: context.colors.error, width: 1.w),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: context.colors.error, width: 1.5.w),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
