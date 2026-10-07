import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

import 'web_product_pagination.dart';
import 'web_product_row.dart';
import 'web_product_utils.dart';
import 'web_product_widgets.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({
    super.key,
    required this.selectedCategory,
    required this.currentPage,
    required this.itemsPerPage,
    required this.compact,
    required this.onPageChanged,
  });

  final int selectedCategory;
  final int currentPage;
  final int itemsPerPage;
  final bool compact;
  final ValueChanged<int> onPageChanged;

  List<ProductModel> _filter(BuildContext context, List<ProductModel> all) {
    var products = List<ProductModel>.from(all);

    if (selectedCategory != 0) {
      final categoryState = context.read<CategoriesCubit>().state;

      if (categoryState is CategoriesLoaded) {
        final categories = categoryState.categories;
        final index = selectedCategory - 1;

        if (index >= 0 && index < categories.length) {
          final selectedName = categories[index].name;

          products = products
              .where((product) => product.category == selectedName)
              .toList();
        }
      }
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return Container(
            height: 420,
            decoration: productContainerDecoration(context),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProductsError) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: productContainerDecoration(context),
            child: Center(child: Text(state.message)),
          );
        }

        if (state is! ProductsSuccess) {
          return const SizedBox.shrink();
        }

        final products = _filter(context, state.products);

        if (products.isEmpty) {
          return _buildEmpty(context);
        }

        final totalItems = products.length;
        final totalPages = (totalItems / itemsPerPage).ceil();

        final safePage = currentPage.clamp(1, totalPages);

        final start = (safePage - 1) * itemsPerPage;

        final end = (start + itemsPerPage).clamp(0, products.length);

        final visibleProducts = products.sublist(start, end);

        return Container(
          width: double.infinity,
          decoration: productContainerDecoration(context),
          child: Column(
            children: [
              _TableHeader(compact: compact),

              for (int i = 0; i < visibleProducts.length; i++) ...[
                ProductRow(
                  product: visibleProducts[i],
                  index: i + start + 1,
                  compact: compact,
                ),
                if (i != visibleProducts.length - 1)
                  Divider(height: 1, color: context.colors.outlineVariant),
              ],

              ProductsPagination(
                page: safePage,
                totalPages: totalPages,
                totalItems: totalItems,
                itemsPerPage: itemsPerPage,
                onPageChanged: onPageChanged,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      decoration: productContainerDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'end_of_products'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: compact
          ? const SizedBox.shrink()
          : const Row(
              children: [
                SizedBox(width: 40),
                Expanded(flex: 4, child: HeaderText('Product')),
                Expanded(flex: 2, child: HeaderText('Barcode')),
                Expanded(flex: 2, child: HeaderText('Category')),
                Expanded(flex: 1, child: HeaderText('Unit')),
                Expanded(flex: 2, child: HeaderText('Price')),
                Expanded(flex: 2, child: HeaderText('Quantity')),
                SizedBox(width: 55),
              ],
            ),
    );
  }
}
