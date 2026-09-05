import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/check_invoice/presentation/layout/check_invoice_mobile.dart';
import 'package:warshity/features/check_invoice/presentation/layout/check_invoice_web.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoice extends StatelessWidget {
  const CheckInvoice({
    super.key,
    required this.invoice,
  });

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: CheckInvoiceMobile(
        invoice: invoice,
      ),
      desktop: CheckInvoiceWeb(
        invoice: invoice,
      ),
    );
  }
}