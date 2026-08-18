import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.prefixIconData,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
    this.maxlines,
  });

  final String? label;
  final String hint;
  final TextEditingController? controller;

  final String? prefixIcon;
  final IconData? prefixIconData;
  final IconButton? suffixIcon;

  final TextInputType? keyboardType;

  final bool obscureText;
  final bool readOnly;

  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  final double? width;
  final double? height;
  final double? borderRadius;
  final int? maxlines;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel)
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

        if (hasLabel) SizedBox(height: 8.h),

        SizedBox(
          width: width ?? 330.w,
          height: height ?? 57.h,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxlines ?? 1,

            textAlignVertical: TextAlignVertical.center,

            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurface,
            ),

            decoration: InputDecoration(
              hintText: hint,

              hintStyle: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),

              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Image.asset(
                        prefixIcon!,
                        width: 24.w,
                        height: 24.h,
                        color: context.colors.onSurfaceVariant,
                        fit: BoxFit.contain,
                      ),
                    )
                  : prefixIconData != null
                  ? Icon(
                      prefixIconData,
                      color: context.colors.onSurfaceVariant,
                      size: 24.sp,
                    )
                  : null,

              suffixIcon: suffixIcon,

              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),

              filled: true,
              fillColor: context.colors.surface,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppRadius.sm,
                ),
                borderSide: BorderSide(color: context.colors.onSurfaceVariant),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppRadius.sm,
                ),
                borderSide: const BorderSide(
                  color: Color(0xffC67A3D),
                  width: 1.5,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppRadius.sm,
                ),
                borderSide: BorderSide(color: context.colors.error),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppRadius.sm,
                ),
                borderSide: BorderSide(color: context.colors.error, width: 1.5),
              ),

              errorStyle: context.text.bodySmall?.copyWith(
                color: context.colors.error,
                height: 1.2,
              ),

              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}
