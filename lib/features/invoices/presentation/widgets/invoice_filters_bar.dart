import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/widgets/app_filter_tabs.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_status_utils.dart';

class InvoiceFiltersBar extends StatelessWidget {
  const InvoiceFiltersBar({
    super.key,
    required this.statusFilter,
    required this.onStatusChanged,
  });

  final InvoiceStatus? statusFilter;
  final ValueChanged<InvoiceStatus?> onStatusChanged;

  static const _timeFilters = [
    (InvoiceFilter.all, 'all'),
    (InvoiceFilter.today, 'today'),
    (InvoiceFilter.thisWeek, 'this_week'),
    (InvoiceFilter.thisMonth, 'this_month'),
  ];

  static const _statusFilters = [
    (InvoiceStatus.paid, 'paid'),
    (InvoiceStatus.partial, 'partially_paid'),
    (InvoiceStatus.unpaid, 'unpaid'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        final cubit = context.read<InvoiceHistoryCubit>();

        // الـ index: الـ time filters الأول (0..3) وبعدها الـ status (4..6)
        final timeCount = _timeFilters.length;

        final selectedIndex = statusFilter != null
            ? timeCount + _statusFilters.indexWhere((e) => e.$1 == statusFilter)
            : _timeFilters.indexWhere((e) => e.$1 == state.filter);

        return AppFilterTabs(
          items: [
            for (final (_, key) in _timeFilters) key.tr(),
            for (final (_, key) in _statusFilters) key.tr(),
          ],
          selectedIndex: selectedIndex,
          onSelected: (index) {
            if (index < timeCount) {
              onStatusChanged(null);
              cubit.changeFilter(_timeFilters[index].$1);
            } else {
              onStatusChanged(_statusFilters[index - timeCount].$1);
              cubit.changeFilter(InvoiceFilter.all);
            }
          },
        );
      },
    );
  }
}
