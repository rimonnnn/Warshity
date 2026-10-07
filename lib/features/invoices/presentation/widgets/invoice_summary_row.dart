import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_status_utils.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_summary_card.dart';

class InvoiceSummaryRow extends StatelessWidget {
  const InvoiceSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        final invoices = state.invoices;
        final loaded = state is InvoiceHistoryLoaded ? state : null;

        final collected = invoices.fold<double>(0, (s, i) => s + i.paidAmount);
        final remaining = invoices.fold<double>(
          0,
          (s, i) => s + i.remainingAmount,
        );

        final cards = [
          InvoiceSummaryCard(
            icon: Icons.payments_outlined,
            title: 'total_collected'.tr(),
            value: money(collected),
            color: context.appColors.success,
          ),
          InvoiceSummaryCard(
            icon: Icons.hourglass_bottom_rounded,
            title: 'remaining'.tr(),
            value: money(remaining),
            color: context.colors.error,
          ),
          InvoiceSummaryCard(
            icon: Icons.today_outlined,
            title: 'today_invoices'.tr(),
            value: '${loaded?.todayInvoices ?? 0}',
            color: context.colors.secondary,
          ),
          InvoiceSummaryCard(
            icon: Icons.receipt_long_outlined,
            title: 'total_invoices'.tr(),
            value: '${loaded?.totalInvoices ?? 0}',
            color: context.colors.primary,
          ),
        ];

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}
