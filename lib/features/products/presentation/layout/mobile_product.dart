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
  final TextEditingController searchController =
      TextEditingController();

  // 0 = All
  // 1+ = Firebase Categories
  int selectedCategory = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>(
      create: (_) =>
          getIt<CategoriesCubit>()..watchCategories(),

      child: Builder(
        builder: (context) {
          // ========================================================
          // مهم جدًا:
          // الـ context ده تحت CategoriesCubit
          // ========================================================

          final categoriesCubit =
              context.read<CategoriesCubit>();

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'products'.tr(),
              ),
              centerTitle: true,
            ),

            // ========================================================
            // ADD PRODUCT
            // ========================================================

            floatingActionButton:
                FloatingAddProductButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,

                  builder: (_) {
                    return MultiBlocProvider(
                      providers: [
                        // نفس CategoriesCubit بتاع الصفحة
                        BlocProvider.value(
                          value: categoriesCubit,
                        ),

                        // Cubit خاص بالـ Add Product
                        BlocProvider(
                          create: (_) =>
                              getIt<AddProductCubit>(),
                        ),
                      ],

                      child:
                          const AddProductDialog(),
                    );
                  },
                );
              },
            ),

            // ========================================================
            // BODY
            // ========================================================

            body: Padding(
              padding: EdgeInsets.all(16.w),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // SEARCH
                  // ==================================================

                  ProductSearchWidget(
                    controller:
                        searchController,
                  ),

                  HeightSpace(16.h),

                  // ==================================================
                  // CATEGORIES
                  // ==================================================

                  BlocBuilder<
                      CategoriesCubit,
                      CategoriesState>(
                    builder:
                        (context, categoryState) {
                      // ----------------------------------------------
                      // Loading
                      // ----------------------------------------------

                      if (categoryState
                          is CategoriesLoading) {
                        return SizedBox(
                          height: 40.h,

                          child:
                              const Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      // ----------------------------------------------
                      // Loaded
                      // ----------------------------------------------

                      if (categoryState
                          is CategoriesLoaded) {
                        final categories =
                            categoryState
                                .categories;

                        final categoryNames = [
                          'all'.tr(),

                          ...categories.map(
                            (category) =>
                                category.name,
                          ),
                        ];

                        // لو category اتحذفت
                        // أو القائمة اتغيرت

                        if (selectedCategory >=
                            categoryNames
                                .length) {
                          selectedCategory = 0;
                        }

                        return ProductCategoryTabs(
                          categories:
                              categoryNames,

                          selectedIndex:
                              selectedCategory,

                          onSelected:
                              (index) {
                            setState(() {
                              selectedCategory =
                                  index;
                            });
                          },
                        );
                      }

                      // ----------------------------------------------
                      // Error
                      // ----------------------------------------------

                      if (categoryState
                          is CategoriesError) {
                        return SizedBox(
                          height: 40.h,

                          child:
                              Center(
                            child: Text(
                              categoryState
                                  .message,
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  HeightSpace(20.h),

                  // ==================================================
                  // PRODUCTS
                  // ==================================================

                  Expanded(
                    child: BlocBuilder<
                        ProductsCubit,
                        ProductsState>(
                      builder:
                          (context, state) {
                        // --------------------------------------------
                        // Loading
                        // --------------------------------------------

                        if (state
                            is ProductsLoading) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        // --------------------------------------------
                        // Success
                        // --------------------------------------------

                        if (state
                            is ProductsSuccess) {
                          var products =
                              state.products;

                          // ------------------------------------------
                          // FILTER BY CATEGORY
                          // ------------------------------------------

                          if (selectedCategory !=
                              0) {
                            final currentCategoryState =
                                categoriesCubit
                                    .state;

                            if (currentCategoryState
                                is CategoriesLoaded) {
                              final categories =
                                  currentCategoryState
                                      .categories;

                              final categoryIndex =
                                  selectedCategory -
                                      1;

                              if (categoryIndex >=
                                      0 &&
                                  categoryIndex <
                                      categories
                                          .length) {
                                final selectedCategoryName =
                                    categories[
                                            categoryIndex]
                                        .name;

                                products =
                                    products
                                        .where(
                                          (product) =>
                                              product
                                                  .category ==
                                              selectedCategoryName,
                                        )
                                        .toList();
                              }
                            }
                          }

                          // ------------------------------------------
                          // Empty
                          // ------------------------------------------

                          if (products.isEmpty) {
                            return const EmptyProductsWidget();
                          }

                          // ------------------------------------------
                          // Product List
                          // ------------------------------------------

                          return SingleChildScrollView(
                            physics:
                                const BouncingScrollPhysics(),

                            child:
                                ProductList(
                              products:
                                  products,
                            ),
                          );
                        }

                        // --------------------------------------------
                        // Error
                        // --------------------------------------------

                        if (state
                            is ProductsError) {
                          return Center(
                            child: Text(
                              state.message,
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