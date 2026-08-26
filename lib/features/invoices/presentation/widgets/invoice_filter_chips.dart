import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';

import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';

class InvoiceFilterChips extends StatelessWidget {
  const InvoiceFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = [
      InvoiceFilter.all,
      InvoiceFilter.today,
      InvoiceFilter.thisWeek,
      InvoiceFilter.thisMonth,
      InvoiceFilter.paid,
      InvoiceFilter.unpaid,
    ];

    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        return SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.md,
            ),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = state.filter == filter;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(_filterName(filter).tr()),
                  selected: isSelected,
                  onSelected: (_) {
                    context
                        .read<InvoiceHistoryCubit>()
                        .changeFilter(filter);
                  },
                  selectedColor:
                      context.colors.primary.withValues(alpha: 0.1),
                  labelStyle:
                      context.text.labelMedium?.copyWith(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor:
                      context.colors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: context.colors.outlineVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _filterName(InvoiceFilter filter) {
    switch (filter) {
      case InvoiceFilter.all:
        return 'all';
      case InvoiceFilter.today:
        return 'today';
      case InvoiceFilter.thisWeek:
        return 'this_week';
      case InvoiceFilter.thisMonth:
        return 'this_month';
      case InvoiceFilter.paid:
        return 'paid';
      case InvoiceFilter.unpaid:
        return 'unpaid';
    }
  }
}