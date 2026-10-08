import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';
import 'package:warshity/features/products/presentation/widgets/product_hero.dart';
import 'package:warshity/features/products/presentation/widgets/product_info_section.dart';
import 'package:warshity/features/products/presentation/widgets/product_not_found.dart';
import 'package:warshity/features/products/presentation/widgets/product_overview.dart';
import 'package:warshity/features/products/presentation/widgets/product_page_header.dart';

class WebProductDetails extends StatelessWidget {
  const WebProductDetails({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          final compact = width < 900;

          return BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoading || state is ProductsInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductsError) {
                return Center(child: Text(state.message));
              }

              final cubit = context.read<ProductsCubit>();

              ProductModel? product;

              for (final item in cubit.allProducts) {
                if (item.id == productId) {
                  product = item;
                  break;
                }
              }

              if (product == null) {
                return ProductNotFound(
                  onBack: () => Navigator.of(context).pop(),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 16 : 30,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1380),
                    child: _buildContent(product: product, compact: compact),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent({required ProductModel product, required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductPageHeader(product: product),
        const SizedBox(height: 18),
        ProductHero(product: product, compact: compact),
        const SizedBox(height: 18),
        ProductOverview(product: product, compact: compact),
        const SizedBox(height: 18),
        ProductInfoSection(product: product),
      ],
    );
  }
}
