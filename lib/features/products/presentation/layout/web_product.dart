import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_details.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_actions.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_categories.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_statistics.dart';
import 'package:warshity/features/products/presentation/widgets/web_product_table.dart';

class WebProduct extends StatefulWidget {
  const WebProduct({super.key});

  @override
  State<WebProduct> createState() => _WebProductState();
}

class _WebProductState extends State<WebProduct> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategory = 0;
  int _currentPage = 1;

  static const int _itemsPerPage = 6;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _currentPage = 1;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 1000;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 20 : 32,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1350),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ProductsHeader(),

                          const SizedBox(height: 20),

                          const ProductsStatistics(),

                          const SizedBox(height: 18),

                          ProductsActions(
                            searchController: _searchController,
                            categoriesCubit: categoriesCubit,
                          ),

                          const SizedBox(height: 16),

                          ProductsCategories(
                            selectedIndex: _selectedCategory,
                            onSelected: (index) {
                              if (_selectedCategory == index) {
                                return;
                              }

                              setState(() {
                                _selectedCategory = index;
                                _currentPage = 1;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          ProductsTable(
                            selectedCategory: _selectedCategory,
                            currentPage: _currentPage,
                            itemsPerPage: _itemsPerPage,
                            compact: isCompact,
                            onPageChanged: (page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            onProductTap: (product) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ProductsCubit>(),
                                    child: WebProductDetails(
                                      productId: product.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
