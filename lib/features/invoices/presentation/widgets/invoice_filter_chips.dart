import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/widgets/app_filter_tabs.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';

class InvoiceFilterChips extends StatelessWidget {
  const InvoiceFilterChips({super.key});

  static const filters = [
    InvoiceFilter.all,
    InvoiceFilter.today,
    InvoiceFilter.thisWeek,
    InvoiceFilter.thisMonth,
    InvoiceFilter.paid,
    InvoiceFilter.unpaid,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      buildWhen: (previous, current) => previous.filter != current.filter,
      builder: (context, state) {
        return AppFilterTabs(
          items: [for (final f in filters) _filterName(f).tr()],
          selectedIndex: filters.indexOf(state.filter),
          onSelected: (index) =>
              context.read<InvoiceHistoryCubit>().changeFilter(filters[index]),
          padding: EdgeInsets.symmetric(horizontal: AppPadding.md),
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
