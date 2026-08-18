import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

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
  final TextEditingController searchController = TextEditingController();

  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);

    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>(
      create: (_) => getIt<CategoriesCubit>()..watchCategories(),

      child: Builder(
        builder: (context) {
          final categoriesCubit = context.read<CategoriesCubit>();

          return Scaffold(
            appBar: AppBar(title: Text('products'.tr()), centerTitle: true),

            floatingActionButton: FloatingAddProductButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,

                  builder: (dialogContext) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: categoriesCubit),

                        BlocProvider(create: (_) => getIt<AddProductCubit>()),
                      ],

                      child: const AddProductDialog(),
                    );
                  },
                );
              },
            ),

            body: Padding(
              padding: EdgeInsets.all(16.w),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  ProductSearchWidget(controller: searchController),

                  HeightSpace(16.h),

                  BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, categoryState) {
                      if (categoryState is CategoriesLoading) {
                        return SizedBox(
                          height: 40.h,

                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (categoryState is CategoriesLoaded) {
                        final categories = categoryState.categories;

                        final List<String> categoryNames = [
                          'all'.tr(),

                          ...categories.map((category) => category.name),
                        ];

                        final int safeSelectedCategory =
                            selectedCategory >= 0 &&
                                selectedCategory < categoryNames.length
                            ? selectedCategory
                            : 0;

                        return ProductCategoryTabs(
                          categories: categoryNames,

                          selectedIndex: safeSelectedCategory,

                          onSelected: (index) {
                            if (index == selectedCategory) {
                              return;
                            }

                            setState(() {
                              selectedCategory = index;
                            });
                          },
                        );
                      }

                      if (categoryState is CategoriesError) {
                        return SizedBox(
                          height: 40.h,

                          child: Center(child: Text(categoryState.message)),
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  HeightSpace(20.h),

                  Expanded(
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, productState) {
                        if (productState is ProductsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (productState is ProductsError) {
                          return Center(child: Text(productState.message));
                        }

                        if (productState is ProductsSuccess) {
                          var products = List.of(productState.products);

                          final String search = searchController.text
                              .trim()
                              .toLowerCase();

                          if (search.isNotEmpty) {
                            products = products.where((product) {
                              final String productName = product.name
                                  .toLowerCase();

                              final String productBarcode = product.barcode
                                  .toLowerCase();

                              return productName.contains(search) ||
                                  productBarcode.contains(search);
                            }).toList();
                          }

                          if (selectedCategory != 0) {
                            final categoryState = categoriesCubit.state;

                            if (categoryState is CategoriesLoaded) {
                              final categories = categoryState.categories;

                              final int categoryIndex = selectedCategory - 1;

                              if (categoryIndex >= 0 &&
                                  categoryIndex < categories.length) {
                                final String selectedCategoryName =
                                    categories[categoryIndex].name;

                                products = products.where((product) {
                                  return product.category ==
                                      selectedCategoryName;
                                }).toList();
                              }
                            }
                          }

                          if (products.isEmpty) {
                            return const EmptyProductsWidget();
                          }

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),

                            child: ProductList(
                              products: products,

                              onDelete: (product) async {
                                try {
                                  await context
                                      .read<ProductsCubit>()
                                      .deleteProduct(product.id);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} deleted successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete product: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }

                        return const EmptyProductsWidget();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
