import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_card.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);

    if (oldDate != null) {
      return DateFormat('dd/MM/yyyy').format(oldDate);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        if (state is InvoiceHistoryLoading && state.invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is InvoiceHistoryError && state.invoices.isEmpty) {
          return Center(child: Text(state.message));
        }

        if (state is! InvoiceHistoryLoaded) {
          return const SizedBox.shrink();
        }

        final invoices = state.filteredInvoices;

        if (invoices.isEmpty) {
          return const Center(child: Text('No invoices found'));
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80.h),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InvoiceCard(
                invoiceNumber: invoice.invoiceId ?? '',
                customerName: invoice.customerName,
                date: _formatDate(invoice.createdAt),
                paymentMethod:
                    invoice.remainingAmount <= 0 ? 'paid' : 'unpaid',
                itemCount: invoice.items.length,
                totalPrice: '\$${invoice.total.toStringAsFixed(2)}',
                status: invoice.remainingAmount <= 0 ? 'paid' : 'unpaid',
              ),
            );
          },
        );
      },
    );
  }
}