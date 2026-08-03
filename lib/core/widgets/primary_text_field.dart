import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
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
  });

  final String label;
  final String hint;

  final TextEditingController? controller;
  final String? prefixIcon;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
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
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: Image.asset(
                        prefixIcon!,
                        width: 24,
                        height: 24,
                        color: context.colors.onSurfaceVariant,
                      ),
                    )
                  : Icon(Icons.email, color: context.colors.onSurfaceVariant),
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
