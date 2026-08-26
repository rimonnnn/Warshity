import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/screens/invoice_screen.dart';

class InvoicePages extends StatelessWidget {
  const InvoicePages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InvoiceHistoryCubit(getIt()),
      child: const InvoiceScreen(),
    );
  }
}
