import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/product_category_dropdown.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/product_image_picker.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/product_price_fields.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/product_quantity_section.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/product_unit_selector.dart';
import 'package:warshity/features/AddProduct/presentation/widgets/save_product_button.dart';
class MobileAddproduct extends StatefulWidget {
  const MobileAddproduct({super.key});

  @override
  State<MobileAddproduct> createState() => _AddProductMobileState();
}

class _AddProductMobileState extends State<MobileAddproduct> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final quantityController = TextEditingController();

  String? selectedCategory;
  String selectedUnit = "piece".tr();

  final categories = [
    "woods".tr(),
    "accessories".tr(),
    "paints".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add_product1".tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImagePicker(
                onTap: () {},
              ),

              HeightSpace(20.h),

              CustomTextField(
                controller: nameController,
                label: "product_name".tr(),
                hint: "product_name_hint".tr(),
                width: double.infinity,
              ),

              HeightSpace(16.h),

              ProductCategoryDropdown(
                value: selectedCategory,
                items: categories,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              HeightSpace(16.h),

              CustomTextField(
                controller: codeController,
                label: "product_code1".tr(),
                hint: "product_code_hint".tr(),
                width: double.infinity,
              ),

              HeightSpace(16.h),

              ProductPriceFields(
                sellingPriceController: sellingPriceController,
                purchasePriceController: purchasePriceController,
              ),

              HeightSpace(16.h),

              ProductQuantitySection(
                controller: quantityController,
              ),

              HeightSpace(16.h),

              ProductUnitSelector(
                selectedUnit: selectedUnit,
                onSelected: (value) {
                  setState(() {
                    selectedUnit = value;
                  });
                },
              ),

              HeightSpace(24.h),

              SaveProductButton(
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}