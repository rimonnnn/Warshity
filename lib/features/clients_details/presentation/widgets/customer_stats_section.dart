import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_tile.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CustomerStatsSection extends StatelessWidget {
  const CustomerStatsSection({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final customerId = customer.id;
    if (customerId == null || customerId.isEmpty) {
      return _buildStats(context, totalPurchases: '—', orderCount: '—');
    }

    return StreamBuilder<List<InvoiceModel>>(
      stream: getIt<InvoicesRepository>().watchAllClientInvoices(customerId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStats(context, totalPurchases: '—', orderCount: '—');
        }

        if (!snapshot.hasData) {
          return _buildStats(context, totalPurchases: '...', orderCount: '...');
        }

        final invoices = snapshot.data!;
        final totalPurchases = invoices.fold<double>(
          0,
          (sum, invoice) => sum + invoice.total,
        );

        return _buildStats(
          context,
          totalPurchases: totalPurchases.toStringAsFixed(1),
          orderCount: invoices.length.toString(),
        );
      },
    );
  }

  Widget _buildStats(
    BuildContext context, {
    required String totalPurchases,
    required String orderCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'customer_details'.tr(),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomerStatTile(
                title: 'total_purchases'.tr(),
                value: totalPurchases,
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomerStatTile(
                title: 'order_count'.tr(),
                value: orderCount,
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
