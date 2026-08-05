import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';

import 'invoice_statistics_card.dart';

class InvoiceStatisticsSection extends StatelessWidget {
  const InvoiceStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(AppPadding.md),
      child: Row(
        children: [
          const InvoiceStatisticsCard(
            title: 'total_invoices',
            value: '150',
            color: 'primary',
          ),
          SizedBox(width: 12.w),
          const InvoiceStatisticsCard(
            title: 'today_invoices',
            value: '25',
            color: 'secondary',
          ),
          SizedBox(width: 12.w),
          const InvoiceStatisticsCard(
            title: 'total_sales',
            value: '\$12,500',
            color: 'success',
          ),
          SizedBox(width: 12.w),
          const InvoiceStatisticsCard(
            title: 'unpaid_invoices',
            value: '8',
            color: 'error',
          ),
        ],
      ),
    );
  }
}
