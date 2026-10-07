import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_radius.dart';

import 'invoice_statistics_card.dart';

class InvoiceStatisticsSectionWeb extends StatelessWidget {
  const InvoiceStatisticsSectionWeb({super.key});

  static const _spacing = 12.0;

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

  /// عدد الأعمدة حسب العرض المتاح فعليًا.
  /// 4 / 2 / 1 بدل 4 / 3 / 2 / 1، عشان الـ 4 كروت مايسيبوش كارت لوحده في سطر.
  static int _columnsFor(double width) {
    if (width >= 1000) return 4;
    if (width >= 480) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppRadius.sm; // نفس الـ padding اللي في الـ Wrap

    return LayoutBuilder(
      builder: (context, constraints) {
        // العرض بعد خصم الـ padding، ده اللي الـ Wrap بيشتغل فيه فعلًا
        final available = constraints.maxWidth - padding;
        final columns = _columnsFor(available);

        // floor عشان كسور البكسل ماتخليش آخر كارت ينزل سطر جديد
        final cardWidth = ((available - _spacing * (columns - 1)) / columns)
            .floorToDouble();

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: [
              for (final card in _cards)
                SizedBox(width: cardWidth, child: card),
            ],
          ),
        );
      },
    );
  }
}
