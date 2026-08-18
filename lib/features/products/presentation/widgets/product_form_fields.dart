import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/products/presentation/widgets/category_dropdown.dart';
import 'package:warshity/features/products/presentation/widgets/product_controllers.dart';
import 'package:warshity/core/widgets/unit_selector.dart';

class ProductFormFields extends StatelessWidget {
  const ProductFormFields({
    super.key,
    required this.controllers,
    required this.selectedCategory,
    required this.selectedUnit,
    required this.units,
    required this.enabled,
    required this.onCategoryChanged,
    required this.onUnitChanged,
  });

  final ProductControllers controllers;

  final String? selectedCategory;
  final String selectedUnit;

  final List<String> units;

  final bool enabled;

  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          width: double.infinity,
          label: 'Product Name'.tr(),
          hint: 'Example: Beech Wood Chair'.tr(),
          controller: controllers.name,
          keyboardType: TextInputType.name,
          prefixIconData: Icons.inventory_2_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product name is required'.tr();
            }

            return null;
          },
        ),

        HeightSpace(16.h),

        CategoryDropdown(
          selectedCategory: selectedCategory,
          enabled: enabled,
          onChanged: onCategoryChanged,
        ),

        HeightSpace(16.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                width: double.infinity,
                label: 'Product Code'.tr(),
                hint: 'SKU-0000',
                controller: controllers.barcode,
                keyboardType: TextInputType.text,
                prefixIconData: Icons.qr_code_2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required'.tr();
                  }

                  return null;
                },
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: CustomTextField(
                width: double.infinity,
                label: 'Selling Price'.tr(),
                hint: '0.00',
                controller: controllers.price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIconData: Icons.payments_outlined,
                validator: AppValidators.amount,
              ),
            ),
          ],
        ),

        HeightSpace(16.h),

        CustomTextField(
          width: double.infinity,
          label: 'Current Quantity'.tr(),
          hint: '0',
          controller: controllers.quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIconData: Icons.inventory_outlined,
          validator: AppValidators.amount,
        ),

        HeightSpace(16.h),

        UnitSelector(
          units: units,
          selectedUnit: selectedUnit,
          enabled: enabled,
          onChanged: onUnitChanged,
        ),
      ],
    );
  }
}
