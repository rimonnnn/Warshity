import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_card.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mocking data for presentation
    final invoices = [
      const InvoiceCard(
        invoiceNumber: 'INV-001',
        customerName: 'John Doe',
        date: 'Aug 04, 2026',
        paymentMethod: 'Card',
        itemCount: 3,
        totalPrice: '\$450.00',
        status: 'paid',
      ),
      const InvoiceCard(
        invoiceNumber: 'INV-002',
        customerName: 'Jane Smith',
        date: 'Aug 03, 2026',
        paymentMethod: 'Bank',
        itemCount: 1,
        totalPrice: '\$1,200.00',
        status: 'unpaid',
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80.h),
      itemCount: invoices.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: invoices[index],
      ),
    );
  }
}
