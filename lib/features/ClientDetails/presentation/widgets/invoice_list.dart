import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/features/ClientDetails/data/invoice_model.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_card.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({
    super.key,
    required this.invoices,
    this.onTap,
  });

  final List<InvoiceClientsModel> invoices;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
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
  }
}