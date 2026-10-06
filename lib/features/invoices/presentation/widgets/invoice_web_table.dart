// lib/features/invoices/presentation/widgets/web/invoice_web_table.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_actions.dart';

enum InvoiceStatus { paid, partial, unpaid }

/// الحالة بتتحسب من paidAmount و remainingAmount بس (مفيش حقل حالة في الموديل).
InvoiceStatus invoiceStatusOf(InvoiceModel invoice) {
  if (invoice.remainingAmount <= 0) return InvoiceStatus.paid;
  if (invoice.paidAmount > 0) return InvoiceStatus.partial;
  return InvoiceStatus.unpaid;
}

String money(double value) => '${value.toStringAsFixed(2)} ${'currency'.tr()}';

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
          return Center(child: Text(state.message));
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'invoices_list'.tr(),
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${invoices.length}',
                        style: context.text.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Row(
                header: true,
                background: colors.surfaceContainerLow,
                cells: [
                  _text(context, 'invoice_numer'.tr(), header: true),
                  _text(context, 'customer'.tr(), header: true),
                  _text(context, 'date'.tr(), header: true),
                  _text(context, 'item_count'.tr(),
                      header: true, align: TextAlign.center),
                  _text(context, 'total_price'.tr(), header: true),
                  _text(context, 'remaining'.tr(), header: true),
                  _text(context, 'invoice_status'.tr(), header: true),
                ],
              ),
              Expanded(
                child: invoices.isEmpty
                    ? Center(child: Text('no_invoice_found'.tr()))
                    : ListView.separated(
                        itemCount: invoices.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colors.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          final selected = invoice.invoiceId == selectedId;

                          return _Row(
                            selected: selected,
                            onTap: () => onSelect(invoice),
                            cells: [
                              _text(context, '#${invoice.invoiceId ?? ''}',
                                  bold: true),
                              _text(context, invoice.customerName),
                              _text(context,
                                  InvoiceWebActions.formatDate(invoice.createdAt)),
                              _text(context, '${invoice.items.length}',
                                  align: TextAlign.center),
                              _text(context, money(invoice.total), bold: true),
                              _text(
                                context,
                                money(invoice.remainingAmount),
                                color: invoice.remainingAmount > 0
                                    ? colors.error
                                    : colors.onSurfaceVariant,
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: _StatusBadge(
                                  status: invoiceStatusOf(invoice),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _flex = [3, 3, 3, 2, 2, 2, 2];

  Widget _text(
    BuildContext context,
    String value, {
    bool header = false,
    bool bold = false,
    TextAlign align = TextAlign.start,
    Color? color,
  }) {
    final style = header
        ? context.text.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          )
        : context.text.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          );

    return Text(
      value,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.cells,
    this.header = false,
    this.selected = false,
    this.background,
    this.onTap,
  });

  final List<Widget> cells;
  final bool header;
  final bool selected;
  final Color? background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : (background ?? Colors.transparent),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: header ? 10 : 14,
          ),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: selected ? colors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                Expanded(flex: InvoiceWebTable._flex[i], child: cells[i]),
                if (i != cells.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      InvoiceStatus.paid => (context.appColors.success, 'paid'),
      InvoiceStatus.partial => (context.appColors.warning, 'partially_paid'),
      InvoiceStatus.unpaid => (context.colors.error, 'unpaid'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.tr(),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
