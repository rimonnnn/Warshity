import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/add_invoices/presentation/layout/mobile_add_invoice.dart';
import 'package:warshity/features/add_invoices/presentation/layout/web_add_invoice.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

class AddInvoice extends StatelessWidget {
  const AddInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>(
      create: (_) => getIt<CategoriesCubit>()..watchCategories(),
      child: AppResponsive(mobile: MobileAddInvoice(), desktop: WebAddInvoice()),
    );
  }
}