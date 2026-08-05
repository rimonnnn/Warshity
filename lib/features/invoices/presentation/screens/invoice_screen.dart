import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_mobile.dart';
import 'package:warshity/features/invoices/presentation/layout/invoice_web.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppResponsive(mobile: InvoiceMobile(), desktop: InvoiceWeb());
  }
}
