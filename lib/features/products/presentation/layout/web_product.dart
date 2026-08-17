import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';

import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

import 'package:warshity/features/products/presentation/widgets/empty_products_widget.dart';
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

  static const int itemsPerPage = 4;

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      currentPage = 1;
    });
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
            backgroundColor: context.colors.surface,

            body: SingleChildScrollView(
              padding: EdgeInsets.all(32.w),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'products'.tr(),

                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      HeightSpace(24.h),

                      Row(
                        children: [
                          Expanded(
                            child: ProductSearchWidget(
                              controller: searchController,
                            ),
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
                              showDialog(
                  context: context,
                  barrierDismissible: true,

                  builder: (dialogContext) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: categoriesCubit),

                        BlocProvider(create: (_) => getIt<AddProductCubit>()),
                      ],

                      child: const AddProductDialog(imagecontainerheight: 250,),
                    );
                  },
                );
                            },

                            icon: const Icon(Icons.add),

                            label: Text('add_product'.tr()),
                          ),
                        ],
                      ),

                      HeightSpace(20.h),

                      BlocBuilder<CategoriesCubit, CategoriesState>(
                        builder: (context, categoryState) {
                          if (categoryState is CategoriesLoading) {
                            return SizedBox(
                              height: 45.h,

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

                                  currentPage = 1;
                                });
                              },
                            );
                          }

                          if (categoryState is CategoriesError) {
                            return SizedBox(
                              height: 45.h,

                              child: Center(child: Text(categoryState.message)),
                            );
                          }

                          return const SizedBox();
                        },
                      ),

                      HeightSpace(20.h),

                      BlocBuilder<ProductsCubit, ProductsState>(
                        builder: (context, productState) {
                          if (productState is ProductsLoading) {
                            return Container(
                              width: double.infinity,

                              height: 300.h,

                              alignment: Alignment.center,

                              child: const CircularProgressIndicator(),
                            );
                          }

                          if (productState is ProductsError) {
                            return Container(
                              width: double.infinity,

                              padding: EdgeInsets.all(30.w),

                              alignment: Alignment.center,

                              child: Text(productState.message),
                            );
                          }

                          if (productState is ProductsSuccess) {
                            List<ProductModel> products =
                                List<ProductModel>.from(productState.products);

                            final String search = searchController.text
                                .trim()
                                .toLowerCase();

                            if (search.isNotEmpty) {
                              products = products.where((ProductModel product) {
                                final String name = product.name.toLowerCase();

                                final String barcode = product.barcode
                                    .toLowerCase();

                                return name.contains(search) ||
                                    barcode.contains(search);
                              }).toList();
                            }

                            if (selectedCategory != 0) {
                              final CategoriesState currentCategoryState =
                                  context.read<CategoriesCubit>().state;

                              if (currentCategoryState is CategoriesLoaded) {
                                final categories =
                                    currentCategoryState.categories;

                                final int categoryIndex = selectedCategory - 1;

                                if (categoryIndex >= 0 &&
                                    categoryIndex < categories.length) {
                                  final String selectedCategoryName =
                                      categories[categoryIndex].name;

                                  products = products.where((
                                    ProductModel product,
                                  ) {
                                    return product.category ==
                                        selectedCategoryName;
                                  }).toList();
                                }
                              }
                            }

                            if (products.isEmpty) {
                              return Container(
                                width: double.infinity,

                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.w,
                                  vertical: 50.h,
                                ),

                                decoration: BoxDecoration(
                                  color: context.colors.surface,

                                  borderRadius: BorderRadius.circular(16.r),

                                  border: Border.all(
                                    color: context.colors.outlineVariant,
                                  ),
                                ),

                                child: const EmptyProductsWidget(),
                              );
                            }

                            final int totalItems = products.length;

                            final int totalPages = (totalItems / itemsPerPage)
                                .ceil();

                            final int safeCurrentPage = currentPage < 1
                                ? 1
                                : currentPage > totalPages
                                ? totalPages
                                : currentPage;

                            final int startIndex =
                                (safeCurrentPage - 1) * itemsPerPage;

                            final int endIndex = (startIndex + itemsPerPage)
                                .clamp(0, products.length);

                            final List<ProductModel> paginatedProducts =
                                products.sublist(startIndex, endIndex);

                            return Container(
                              width: double.infinity,

                              decoration: BoxDecoration(
                                color: context.colors.surface,

                                borderRadius: BorderRadius.circular(16.r),

                                border: Border.all(
                                  color: context.colors.outlineVariant,
                                ),
                              ),

                              child: Column(
                                children: [
                                  ProductList(
                                    products: paginatedProducts,

                                    height: 80,

                                    width: 80,

                                    padding: EdgeInsets.all(16.w),
                                  ),

                                  Divider(
                                    height: 1,

                                    color: context.colors.outlineVariant,
                                  ),

                                  ProductsPagination(
                                    currentPage: safeCurrentPage,

                                    totalPages: totalPages,

                                    totalItems: totalItems,

                                    itemsPerPage: itemsPerPage,

                                    onPageChanged: (page) {
                                      if (page == currentPage) {
                                        return;
                                      }

                                      setState(() {
                                        currentPage = page;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            width: double.infinity,

                            padding: EdgeInsets.all(40.w),

                            child: const EmptyProductsWidget(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
