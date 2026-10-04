import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

import 'web_product_utils.dart';

class ProductsStatistics extends StatelessWidget {
  const ProductsStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is! ProductsSuccess) {
          return const SizedBox.shrink();
        }

        final products = state.products;

        final totalProducts = products.length;

        final totalQuantity = products.fold<int>(
          0,
          (sum, product) => sum + product.quantity,
        );

        final inventoryValue = products.fold<double>(
          0,
          (sum, product) => sum + (product.price * product.quantity),
        );

        final outOfStock = products
            .where((product) => product.quantity == 0)
            .length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;

            final cards = [
              StatisticCard(
                icon: Icons.inventory_2_outlined,
                title: 'total_products'.tr(),
                value: '$totalProducts',
                subtitle: 'products'.tr(),
              ),
              StatisticCard(
                icon: Icons.numbers_outlined,
                title: 'total_quantity'.tr(),
                value: '$totalQuantity',
                subtitle: 'quantity'.tr(),
              ),
              StatisticCard(
                icon: Icons.payments_outlined,
                title: 'inventory_value'.tr(),
                value: formatMoney(inventoryValue),
                subtitle: 'EGP'.tr(),
              ),
              StatisticCard(
                icon: Icons.warning_amber_outlined,
                title: 'out_of_stock'.tr(),
                value: '$outOfStock',
                subtitle: 'products'.tr(),
                warning: outOfStock > 0,
              ),
            ];

            if (compact) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i != cards.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final accent = warning ? Colors.orange : context.colors.primary;

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    color: warning ? Colors.orange : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
