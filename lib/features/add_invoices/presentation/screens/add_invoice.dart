import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/layout/mobile_add_invoice.dart';
import 'package:warshity/features/add_invoices/presentation/layout/web_add_invoice.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

class AddInvoice extends StatelessWidget {
  const AddInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ClientsCubit>()..watchClients()),
        BlocProvider(
          create: (_) => getIt<CategoriesCubit>()..watchCategories(),
        ),
        BlocProvider(create: (_) => getIt<ProductsCubit>()..watchProducts()),
      ],
      child: AppResponsive(
        mobile: MobileAddInvoice(),
        desktop: WebAddInvoice(),
      ),
    );
  }
}
