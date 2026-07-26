import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.selectedItem,
    this.onSelected,
    this.prefixIcon,
    this.width,
    this.height,
    this.borderRadius,
    this.validator,
  });

  final String label;
  final String hint;

  final List<String> items;
  final String? selectedItem;

  final String? prefixIcon;

  final double? width;
  final double? height;
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width ?? 330.w,
          height: height ?? 60.h,
          child: DropdownSearch<String>(
            items: (filter, infiniteScrollProps) => items,

            selectedItem: selectedItem,

            onSelected: onSelected,

            validator: validator,

            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: hint,

                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          prefixIcon!,
                          width: 24,
                          height: 24,
                        ),
                      )
                    : null,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),

                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
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

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: const BorderSide(
                    color: Colors.red,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppRadius.sm,
                  ),
                  borderSide: const BorderSide(
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "search".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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