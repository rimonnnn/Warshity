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

class AddProductWeb extends StatefulWidget {
  const AddProductWeb({super.key});

  @override
  State<AddProductWeb> createState() => _AddProductWebState();
}

class _AddProductWebState extends State<AddProductWeb> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final quantityController = TextEditingController();

  String? selectedCategory;
  String selectedUnit = "piece".tr();

  late final List<String> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    categories = ["woods".tr(), "accessories".tr(), "paints".tr()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "add_product".tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                HeightSpace(32.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Left Side
                    Expanded(
                      child: ProductImagePicker(height: 250, onTap: () {}),
                    ),

                    WidthSpace(32),

                    /// Right Side
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            label: "product_name".tr(),
                            hint: "product_name_hint".tr(),
                            width: double.infinity,
                          ),

                          HeightSpace(20),

                          ProductCategoryDropdown(
                            value: selectedCategory,
                            horizontalPadding: 20,
                            verticalPadding: 16,
                            items: categories,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),

                          HeightSpace(20),

                          CustomTextField(
                            controller: codeController,
                            label: "product_code".tr(),
                            hint: "product_code_hint".tr(),
                            width: double.infinity,
                          ),

                          HeightSpace(20),

                          ProductPriceFields(
                            sellingPriceController: sellingPriceController,
                            purchasePriceController: purchasePriceController,
                            widthspace: 12,
                          ),

                          HeightSpace(20),

                          ProductQuantitySection(
                            controller: quantityController,
                          ),

                          HeightSpace(20),

                          ProductUnitSelector(
                            selectedUnit: selectedUnit,
                            onSelected: (value) {
                              setState(() {
                                selectedUnit = value;
                              });
                            },
                          ),

                          HeightSpace(32),

                          SaveProductButton(onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
