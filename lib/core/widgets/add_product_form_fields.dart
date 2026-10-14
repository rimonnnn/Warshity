import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/product_image_picker.dart';
import 'package:warshity/core/widgets/unit_selector.dart';
import 'package:warshity/features/products/presentation/widgets/category_dropdown.dart';

class AddProductFormFields extends StatelessWidget {
  const AddProductFormFields({
    super.key,
    required this.isWeb,
    required this.isSaving,
    required this.nameController,
    required this.barcodeController,
    required this.priceController,
    required this.quantityController,
    required this.selectedImageBytes,
    required this.selectedCategory,
    required this.selectedUnit,
    required this.units,
    required this.imageHeight,
    required this.onPickImage,
    required this.onCategoryChanged,
    required this.onUnitChanged,
    this.productNameFieldHeight,
    this.productCodeFieldHeight,
    this.sellingPriceFieldHeight,
    this.currentQuantityFieldHeight,
  });

  final bool isWeb;
  final bool isSaving;

  final TextEditingController nameController;
  final TextEditingController barcodeController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  final Uint8List? selectedImageBytes;
  final String? selectedCategory;
  final String selectedUnit;
  final List<String> units;

  final double imageHeight;
  final double? productNameFieldHeight;
  final double? productCodeFieldHeight;
  final double? sellingPriceFieldHeight;
  final double? currentQuantityFieldHeight;

  final VoidCallback onPickImage;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final double iconSize = isWeb ? 28 : 24.sp;
    final double gap = isWeb ? 16 : 14.h; // مسافة موحدة بين الحقول
    final double rowGap = isWeb ? 14 : 10.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImagePicker(
          imageBytes: selectedImageBytes,
          height: imageHeight,
          onPick: onPickImage,
          enabled: !isSaving,
        ),

        SizedBox(height: gap),

        CustomTextField(
          width: double.infinity,
          height: productNameFieldHeight,
          label: 'Product Name'.tr(),
          hint: 'prpduct_name_hint'.tr(),
          iconSize: iconSize,
          controller: nameController,
          keyboardType: TextInputType.name,
          prefixIconData: Icons.inventory_2_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product name is required'.tr();
            }
            return null;
          },
        ),

        SizedBox(height: gap),

        CategoryDropdown(
          selectedCategory: selectedCategory,
          enabled: !isSaving,
          onChanged: onCategoryChanged,
        ),

        SizedBox(height: gap),

        LayoutBuilder(
          builder: (context, innerConstraints) {
            final bool narrow = innerConstraints.maxWidth < 520;

            final codeField = CustomTextField(
              width: double.infinity,
              label: 'Product Code'.tr(),
              height: productCodeFieldHeight,
              hint: 'generating_product_code'.tr(),
              controller: barcodeController,
              iconSize: iconSize,
              keyboardType: TextInputType.text,
              prefixIconData: Icons.qr_code_2,
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'required'.tr();
                }
                return null;
              },
            );

            final priceField = CustomTextField(
              width: double.infinity,
              label: 'Selling Price'.tr(),
              hint: '0.00',
              iconSize: iconSize,
              controller: priceController,
              height: sellingPriceFieldHeight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIconData: Icons.payments_outlined,
              validator: AppValidators.amount,
            );

            if (narrow) {
              return Column(
                children: [
                  codeField,
                  SizedBox(height: gap),
                  priceField,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: codeField),
                SizedBox(width: rowGap),
                Expanded(child: priceField),
              ],
            );
          },
        ),

        SizedBox(height: gap),

        CustomTextField(
          width: double.infinity,
          label: 'Current Quantity'.tr(),
          iconSize: iconSize,
          height: currentQuantityFieldHeight,
          hint: '0',
          controller: quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIconData: Icons.inventory_outlined,
          validator: AppValidators.amount,
        ),

        SizedBox(height: gap),

        UnitSelector(
          units: units,
          selectedUnit: selectedUnit,
          enabled: !isSaving,
          onChanged: onUnitChanged,
        ),
      ],
    );
  }
}
