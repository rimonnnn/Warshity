import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_review_panel.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_empty_panel.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_filter_chips.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_stats_row.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_table.dart';

class InvoiceWeb extends StatefulWidget {
  const InvoiceWeb({super.key});

  @override
  State<InvoiceWeb> createState() => _InvoiceWebState();
}

class _InvoiceWebState extends State<InvoiceWeb> {
  final TextEditingController searchController = TextEditingController();
  static const _wideBreakpoint = 900.0;
  static const _panelWidth = 380.0;

  String? _selectedId;
  InvoiceStatus? _statusFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
    return Container(
      width: double.infinity,
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          const InvoiceWebStatsRow(),
          const SizedBox(height: 16),
          InvoiceSearchBar(
            controller: searchController,
            onChanged: (value) {
              context.read<InvoiceHistoryCubit>().searchInvoices(value);
            },
          ),
          const SizedBox(height: 8),
          InvoiceWebFilterChips(
            statusFilter: _statusFilter,
            onStatusChanged: (s) => setState(() => _statusFilter = s),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= _wideBreakpoint;

                final table = InvoiceWebTable(
                  selectedId: wide ? _selectedId : null,
                  statusFilter: _statusFilter,
                  onSelect: (i) => _select(i, wide: wide),
                );

                if (!wide) return table;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: table),
                    const SizedBox(width: 24),
                    SizedBox(width: _panelWidth, child: _buildPanel()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'invoice_history'.tr(),
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IntrinsicWidth(
          child: ElevatedButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.addInvoicesScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'add_invoice'.tr(),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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

        if (invoice == null) return const InvoiceWebEmptyPanel();

        return InvoiceReviewPanel(
          key: ValueKey(invoice.invoiceId),
          invoice: invoice,
          onClose: () => setState(() => _selectedId = null),
          onDeleted: () => setState(() => _selectedId = null),
        );
      },
    );
  }
}
