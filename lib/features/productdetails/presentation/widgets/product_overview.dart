import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/features/products/data/models/product_model.dart';

import 'metric_card.dart';
import 'product_price_formatter.dart';

class ProductOverview extends StatelessWidget {
  const ProductOverview({
    super.key,
    required this.product,
    required this.compact,
  });

  final ProductModel product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
        icon: Icons.inventory_2_outlined,
        title: 'current_quantity'.tr(),
        value: '${product.quantity}',
        subtitle: product.unit,
      ),
      MetricCard(
        icon: Icons.payments_outlined,
        title: 'selling_price'.tr(),
        value: formatPrice(product.price),
        subtitle: 'EGP'.tr(),
      ),
      MetricCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'inventory_value'.tr(),
        value: formatPrice(product.price * product.quantity),
        subtitle: 'EGP'.tr(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = compact
            ? (width >= 560 ? 2 : 1)
            : width >= 900
            ? 3
            : width >= 560
            ? 2
            : 1;
        final spacing = 12.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
