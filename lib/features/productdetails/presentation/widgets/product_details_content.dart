import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_hero.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_info_section.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_not_found.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_overview.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_page_header.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

/// Shared loading, product lookup, and responsive layout for mobile and web.
class ProductDetailsContent extends StatelessWidget {
  const ProductDetailsContent({
    super.key,
    required this.productId,
    this.forceCompactLayout = false,
  });

  final String productId;
  final bool forceCompactLayout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final compact = forceCompactLayout || screenWidth < 900;

            return BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading || state is ProductsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
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
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }

                final horizontalPadding = screenWidth < 380
                    ? 12.0
                    : screenWidth < 600
                    ? 16.0
                    : compact
                    ? 20.0
                    : 30.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: screenWidth < 600 ? 14 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1380),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProductPageHeader(product: product),
                          const SizedBox(height: 16),
                          ProductHero(product: product, compact: compact),
                          const SizedBox(height: 16),
                          ProductOverview(product: product, compact: compact),
                          const SizedBox(height: 16),
                          ProductInfoSection(product: product),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
