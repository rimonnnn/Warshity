import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_card.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({
    super.key,
    required this.customerId,
    this.onTap,
  });

  final String customerId;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InvoiceModel>>(
      stream: getIt<InvoicesRepository>().watchClientInvoices(
        customerId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final invoices = snapshot.data ?? [];

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            return InvoiceCard(
              invoice: invoices[index],
              onTap: () => onTap?.call(index),
            );
          },
        );
      },
    );
  }
}