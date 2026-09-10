import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/all_client_invoices_shimmer.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_card.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class AllClientInvoices extends StatelessWidget {
  const AllClientInvoices({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('invoice_history'.tr())),
      body: StreamBuilder<List<InvoiceModel>>(
        stream: getIt<InvoicesRepository>().watchAllClientInvoices(customerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AllClientInvoicesShimmer());
          }

          if (snapshot.hasError) {
            return Center(child: Text('something_error'.tr()));
          }

          final invoices = snapshot.data ?? [];

          if (invoices.isEmpty) {
            return Center(child: Text('no_invoice_found'.tr()));
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              return InvoiceCard(invoice: invoices[index]);
            },
          );
        },
      ),
    );
  }
}
