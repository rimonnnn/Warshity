import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/add_invoices/presentation/layout/mobile_add_invoice.dart';
import 'package:warshity/features/add_invoices/presentation/layout/web_add_invoice.dart';

class AddInvoice extends StatelessWidget {
  const AddInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    return AppResponsive(mobile: MobileAddInvoice(), desktop: WebAddInvoice());
  }
}