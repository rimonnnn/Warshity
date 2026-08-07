import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductCategoryDropdown extends StatelessWidget {
  const ProductCategoryDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.width,
    this.height,
    this.borderRadius, this.horizontalPadding, this.verticalPadding,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  final double? width;
  final double? height;
  final double? borderRadius;
final double? horizontalPadding;
final double? verticalPadding;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "category".tr(),
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        SizedBox(
          width: width ?? double.infinity,
          height: height ?? 57.h,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.colors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding ?? 20.w,
                vertical: verticalPadding ?? 16.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? AppRadius.sm,
                ),
                borderSide: BorderSide(
                  color: context.colors.onSurfaceVariant,
                ),
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
            ),
            hint: Text("select_category".tr()),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}