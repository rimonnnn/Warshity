import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_details_placeholder.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_filters_bar.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_history_header.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_review_panel.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_summary_row.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_table.dart';

class InvoiceWeb extends StatefulWidget {
  const InvoiceWeb({super.key});

  @override
  State<InvoiceWeb> createState() => _InvoiceWebState();
}

class _InvoiceWebState extends State<InvoiceWeb> {
  static const _wideBreakpoint = 900.0;
  static const _panelWidth = 380.0;

  String? _selectedId;
  InvoiceStatus? _statusFilter;

  void _select(InvoiceModel invoice, {required bool wide}) {
    if (wide) {
      setState(() => _selectedId = invoice.invoiceId);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: 440,
          height: MediaQuery.sizeOf(dialogContext).height * 0.85,
          child: InvoiceReviewPanel(
            invoice: invoice,
            onClose: () => Navigator.pop(dialogContext),
            onDeleted: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,

      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: context.colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InvoiceHistoryHeader(),
              const SizedBox(height: 20),
              const InvoiceSummaryRow(),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _wideBreakpoint;

                  if (!wide) return _buildList(wide: false);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildList(wide: true)),
                      const SizedBox(width: 24),
                      SizedBox(width: _panelWidth, child: _buildPanel()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InvoiceSearchBar(),
        const SizedBox(height: 8),
        InvoiceFiltersBar(
          statusFilter: _statusFilter,
          onStatusChanged: (s) => setState(() => _statusFilter = s),
        ),
        const SizedBox(height: 16),
        InvoiceWebTable(
          selectedId: wide ? _selectedId : null,
          statusFilter: _statusFilter,
          onSelect: (i) => _select(i, wide: wide),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        final invoice = _selectedId == null
            ? null
            : state.invoices
                  .where((i) => i.invoiceId == _selectedId)
                  .firstOrNull;

        if (invoice == null) return const InvoiceDetailsPlaceholder();

        return InvoiceReviewPanel(
          key: ValueKey(invoice.invoiceId),
          invoice: invoice,
          useInternalScroll: false,
          onClose: () => setState(() => _selectedId = null),
          onDeleted: () => setState(() => _selectedId = null),
        );
      },
    );
  }
}
