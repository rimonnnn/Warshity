import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceInformation extends StatelessWidget {
  final InvoiceModel invoiceModel;

  const CheckInvoiceInformation({super.key, required this.invoiceModel});

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);

    if (oldDate != null) {
      return DateFormat('dd/MM/yyyy').format(oldDate);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('invoice_numer'.tr(), style: context.text.bodyMedium),
            const SizedBox(height: 8),
            Text('date'.tr(), style: context.text.bodyMedium),
            const SizedBox(height: 8),
            Text('customer'.tr(), style: context.text.bodyMedium),
          ],
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                invoiceModel.invoiceId ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),

              const SizedBox(height: 8),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _formatDate(invoiceModel.createdAt),
                  style: context.text.bodyMedium,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                invoiceModel.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
