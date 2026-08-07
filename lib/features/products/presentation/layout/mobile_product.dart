import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/products/data/product_model.dart';
import 'package:warshity/features/products/presentation/widgets/empty_products_widget.dart';
import 'package:warshity/features/products/presentation/widgets/floating_add_product_button.dart';
import 'package:warshity/features/products/presentation/widgets/product_category_tabs.dart';
import 'package:warshity/features/products/presentation/widgets/product_list.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';

class MobileProduct extends StatefulWidget {
  const MobileProduct({super.key});

  @override
  State<MobileProduct> createState() => _MobileProductsState();
}

class _MobileProductsState extends State<MobileProduct> {
  final searchController = TextEditingController();

  int selectedCategory = 0;

  final categories = [
    "all".tr(),
    "woods".tr(),
    "accessories".tr(),
    "paints".tr(),
  ];

  final products = [
    ProductModel(
      name: "product_wood_swedish".tr(),
      code: "PRD-002",
      price: "price_320".tr(),
      quantity: "quantity_45_meter".tr(),
      image: Image.asset(AppAssets.product1, fit: BoxFit.cover),
      icon: Icons.edit_outlined,
    ),
    ProductModel(
      name: "product_stainless_hinge".tr(),
      code: "PRD-010",
      price: "price_40".tr(),
      quantity: "quantity_120_piece".tr(),
      icon: Icons.edit_outlined,
      image: Image.asset(AppAssets.product2, fit: BoxFit.cover),
    ),
    ProductModel(
      name: "product_lacquer_paint".tr(),
      code: "PRD-030",
      price: "price_550".tr(),
      quantity: "quantity_18_can".tr(),
      icon: Icons.edit_outlined,
      image: Image.asset(AppAssets.product3, fit: BoxFit.cover),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("products".tr()), centerTitle: true),

      floatingActionButton: FloatingAddProductButton(onPressed: () {}),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSearchWidget(controller: searchController),

            HeightSpace(16.h),

            ProductCategoryTabs(
              categories: categories,
              selectedIndex: selectedCategory,
              onSelected: (index) {
                setState(() {
                  selectedCategory = index;
                });
              },
            ),

            HeightSpace(20.h),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProductList(products: products),

                    EmptyProductsWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
