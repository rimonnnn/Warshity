import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomDropdownProducts extends StatelessWidget {
  const CustomDropdownProducts({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.selectedItem,
    this.onSelected,
    this.prefixIcon,
    this.width,
    this.borderRadius,
    this.validator,
  });

  final String label;
  final String hint;

  final List<String> items;
  final String? selectedItem;

  final String? prefixIcon;

  final double? width;
  final double? borderRadius;

  final void Function(String?)? onSelected;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          // مفيش height ثابت هنا — نفس منطق CustomTextField، عشان لو ظهرت
          // رسالة خطأ من الـ validator، تتحط تحت من غير overflow
          width: width ?? 330.w,
          child: DropdownSearch<String>(
            items: (filter, infiniteScrollProps) => items,
            selectedItem: selectedItem,
            onSelected: onSelected,
            validator: validator,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: EdgeInsets.all(16.sp),
                        child: Image.asset(
                          prefixIcon!,
                          width: 24.w,
                          height: 24.h,
                          color: context.colors.onSurfaceVariant,
                        ),
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 18.h,
                ),
                filled: true,
                fillColor: context.colors.surface,
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
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 1.5.w,
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
                  borderSide: BorderSide(
                    color: context.colors.error,
                    width: 1.5.w,
                  ),
                ),
                errorStyle: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              containerBuilder: (context, popupWidget) {
                return Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: popupWidget,
                );
              },
              searchFieldProps: TextFieldProps(
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "search".tr(),
                  hintStyle: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
