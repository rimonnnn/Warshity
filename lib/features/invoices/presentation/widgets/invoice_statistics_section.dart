import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/constants/app_padding.dart';

import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';

import 'invoice_statistics_card.dart';

class InvoiceStatisticsSection extends StatelessWidget {
  const InvoiceStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        final totalInvoices = state is InvoiceHistoryLoaded
            ? state.totalInvoices
            : 0;

        final todayInvoices = state is InvoiceHistoryLoaded
            ? state.todayInvoices
            : 0;

        final totalSales = state is InvoiceHistoryLoaded
            ? state.totalSales
            : 0;

        final unpaidInvoices = state is InvoiceHistoryLoaded
            ? state.unpaidInvoices
            : 0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(AppPadding.md),
          child: Row(
            children: [
              InvoiceStatisticsCard(
                title: 'total_invoices',
                value: '$totalInvoices',
                color: 'primary',
              ),

              SizedBox(width: 12.w),

              InvoiceStatisticsCard(
                title: 'today_invoices',
                value: '$todayInvoices',
                color: 'secondary',
              ),

              SizedBox(width: 12.w),

              InvoiceStatisticsCard(
                title: 'total_sales',
                value: '\$${totalSales.toStringAsFixed(2)}',
                color: 'success',
              ),

              SizedBox(width: 12.w),

              InvoiceStatisticsCard(
                title: 'unpaid_invoices',
                value: '$unpaidInvoices',
                color: 'error',
              ),
            ],
          ),
        );
      },
    );
  }
}