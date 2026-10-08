import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_tile.dart';

class CustomerStatsSection extends StatelessWidget {
  const CustomerStatsSection({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'customer_details'.tr(),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomerStatTile(
                title: 'total_purchases'.tr(),
                value: customer.totalPurchases.toString(),
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomerStatTile(
                title: 'order_count'.tr(),
                value: customer.orderCount.toString(),
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
