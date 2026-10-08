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
        if (compact || constraints.maxWidth < 850) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final card in cards)
                SizedBox(width: (constraints.maxWidth - 12) / 2, child: card),
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}
