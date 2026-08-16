import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/widgets/product_category_tabs.dart';
import 'package:warshity/features/products/presentation/widgets/product_list.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';
import 'package:warshity/features/products/presentation/widgets/products_pagination.dart';

class WebProduct extends StatefulWidget {
  const WebProduct({super.key});

  @override
  State<WebProduct> createState() => _WebProductState();
}

class _WebProductState extends State<WebProduct> {
  final TextEditingController searchController = TextEditingController();

  int selectedCategory = 0;
  int currentPage = 1;

  late final List<String> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    categories = ["all".tr(), "woods".tr(), "accessories".tr(), "paints".tr()];
  }

  final products = [
    ProductModel(
      id: "1",
      name: "product_wood_swedish".tr(),
      barcode: "PRD-002",
      category: "Wood",
      price: 320,
      quantity: 45,
      unit: "m",
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/en/thumb/4/44/Red_Dead_Redemption_II.jpg/250px-Red_Dead_Redemption_II.jpg",
    ),
    ProductModel(
      id: "2",
      name: "product_stainless_hinge".tr(),
      barcode: "PRD-010",
      category: "Accessories",
      price: 40,
      quantity: 120,
      unit: "piece",
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/en/thumb/4/44/Red_Dead_Redemption_II.jpg/250px-Red_Dead_Redemption_II.jpg",
    ),
    ProductModel(
      id: "3",
      name: "product_lacquer_paint".tr(),
      barcode: "PRD-030",
      category: "Paints",
      price: 550,
      quantity: 18,
      unit: "can",
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/en/thumb/4/44/Red_Dead_Redemption_II.jpg/250px-Red_Dead_Redemption_II.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "products".tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              HeightSpace(24.h),

              Row(
                children: [
                  Expanded(
                    child: ProductSearchWidget(controller: searchController),
                  ),
                  SizedBox(width: 16.w),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 18.h,
                      ),
                    ),
                    onPressed: () {
                      context.pushNamed(AppRoutes.addproductScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: Text("add_product".tr()),
                  ),
                ],
              ),

              HeightSpace(20.h),

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

              Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: context.colors.outlineVariant),
                ),
                child: Column(
                  children: [
                    ProductList(
                      products: products,
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(16.w),
                    ),

                    Divider(height: 1, color: context.colors.outlineVariant),

                    ProductsPagination(
                      currentPage: currentPage,
                      totalPages: 3,
                      totalItems: 12,
                      itemsPerPage: 4,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
