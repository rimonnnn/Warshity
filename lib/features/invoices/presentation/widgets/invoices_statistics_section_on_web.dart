import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';

import 'invoice_statistics_card.dart';

class InvoiceStatisticsSectionWeb extends StatelessWidget {
  const InvoiceStatisticsSectionWeb({super.key});

  static const _cards = [
    InvoiceStatisticsCard(
      title: 'total_invoices',
      value: '150',
      color: 'primary',
    ),
    InvoiceStatisticsCard(
      title: 'today_invoices',
      value: '25',
      color: 'secondary',
    ),
    InvoiceStatisticsCard(
      title: 'total_sales',
      value: '\$12,500',
      color: 'success',
    ),
    InvoiceStatisticsCard(title: 'unpaid_invoices', value: '8', color: 'error'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final cardWidth = switch (width) {
          > 1200 => (width - 36) / 4,
          > 900 => (width - 24) / 3,
          > 600 => (width - 12) / 2,
          _ => width,
        };

        return Padding(
          padding: EdgeInsets.all(AppPadding.md),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _cards.map((card) {
              return SizedBox(width: cardWidth, child: card);
            }).toList(),
          ),
        );
      },
    );
  }
}
