import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomSearchTextField extends StatelessWidget {
  const CustomSearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
    this.textInputAction,
    this.focusNode, this.width, this.height,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  final bool readOnly;
  final bool enabled;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final Color? fillColor;
  final Color? borderColor;

  final double? borderRadius;

  final EdgeInsetsGeometry? contentPadding;

  final TextInputAction? textInputAction;

  final FocusNode? focusNode;
final double? width;
final double? height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 330.w,
      height: height ?? 50.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        enabled: enabled,
        textInputAction: textInputAction ?? TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText ?? "ابحث...",
          hintStyle: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
      
          prefixIcon: prefixIcon ??
              Icon(
                Icons.search_rounded,
                color: context.colors.onSurfaceVariant,
              ),
      
          suffixIcon: suffixIcon,
      
          filled: true,
          fillColor: fillColor ?? context.colors.surfaceContainerLow,
      
          contentPadding:
              contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
      
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppRadius.lg,
            ),
            borderSide: BorderSide(
              color: borderColor ?? context.colors.outlineVariant,
            ),
          ),
      
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppRadius.lg,
            ),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 1.5,
            ),
          ),
      
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppRadius.lg,
            ),
          ),
        ),
      ),
    );
  }
}