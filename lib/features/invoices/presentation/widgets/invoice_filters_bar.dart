import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (filter, key) in _timeFilters)
                _chip(
                  context,
                  label: key.tr(),
                  selected: statusFilter == null && state.filter == filter,
                  onTap: () {
                    onStatusChanged(null);
                    cubit.changeFilter(filter);
                  },
                ),
              for (final (status, key) in _statusFilters)
                _chip(
                  context,
                  label: key.tr(),
                  selected: statusFilter == status,
                  onTap: () {
                    onStatusChanged(status);
                    cubit.changeFilter(InvoiceFilter.all);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colors.primary.withValues(alpha: 0.1),
      backgroundColor: colors.surfaceContainerLow,
      labelStyle: context.text.labelMedium?.copyWith(
        color: selected ? colors.primary : colors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
    );
  }
}
