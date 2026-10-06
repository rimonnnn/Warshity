import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_web_table.dart';

class InvoiceWebStatsRow extends StatelessWidget {
  const InvoiceWebStatsRow({super.key});

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
          InvoiceStatCard(
            icon: Icons.payments_outlined,
            title: 'total_collected'.tr(),
            value: money(collected),
            color: context.appColors.success,
          ),
          InvoiceStatCard(
            icon: Icons.hourglass_bottom_rounded,
            title: 'remaining'.tr(),
            value: money(remaining),
            color: context.colors.error,
          ),
          InvoiceStatCard(
            icon: Icons.today_outlined,
            title: 'today_invoices'.tr(),
            value: '${loaded?.todayInvoices ?? 0}',
            color: context.colors.secondary,
          ),
          InvoiceStatCard(
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

class InvoiceStatCard extends StatelessWidget {
  const InvoiceStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
