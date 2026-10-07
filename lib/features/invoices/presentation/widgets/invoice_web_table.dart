import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_list_item.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_status_utils.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_table_row.dart';

// Keeps old imports working (InvoiceStatus, invoiceStatusOf, money).
export 'package:warshity/features/invoices/presentation/widgets/invoice_status_utils.dart';

class InvoiceWebTable extends StatelessWidget {
  const InvoiceWebTable({
    super.key,
    required this.selectedId,
    required this.onSelect,
    this.statusFilter,
  });

  final String? selectedId;
  final ValueChanged<InvoiceModel> onSelect;
  final InvoiceStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        if (state is InvoiceHistoryError && state.invoices.isEmpty) {
          return Center(
            child: Text(
              state.message,
              style: context.text.bodyMedium?.copyWith(color: colors.error),
            ),
          );
        }

        var invoices = state is InvoiceHistoryLoaded
            ? state.filteredInvoices
            : <InvoiceModel>[];

        if (statusFilter != null) {
          invoices = invoices
              .where((i) => invoiceStatusOf(i) == statusFilter)
              .toList();
        }

        return Container(
          decoration: BoxDecoration(
            // surfaceContainer بدل surface، عشان الجدول يبان فوق الخلفية
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildTitle(context, invoices.length),
              _buildHeader(context),
              invoices.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'no_invoice_found'.tr(),
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < invoices.length; i++) ...[
                          InvoiceHistoryRow(
                            invoice: invoices[i],
                            selectedId: selectedId,
                            onSelect: onSelect,
                          ),
                          if (i != invoices.length - 1)
                            Divider(height: 1, color: colors.outlineVariant),
                        ],
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, int count) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'invoices_list'.tr(),
            style: context.text.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: context.text.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InvoiceRow(
      header: true,
      background: context.colors.surfaceContainerHigh,
      cells: [
        _headerText(context, 'invoice_numer'.tr()),
        _headerText(context, 'customer'.tr()),
        _headerText(context, 'date'.tr()),
        _headerText(context, 'item_count'.tr(), align: TextAlign.center),
        _headerText(context, 'total_price'.tr()),
        _headerText(context, 'remaining'.tr()),
        _headerText(context, 'invoice_status'.tr()),
      ],
    );
  }

  Widget _headerText(
    BuildContext context,
    String value, {
    TextAlign align = TextAlign.start,
  }) {
    return Text(
      value,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.labelLarge?.copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
