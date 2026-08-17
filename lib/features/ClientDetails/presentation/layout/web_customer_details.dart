import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/app_loading_indicator.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/Cleints/presentation/cubit/debt_cubit.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_debt_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_header_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_stat_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/decrease_debt_dialog.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_list.dart';

class WebCustomerDetails extends StatelessWidget {
  const WebCustomerDetails({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final repository = getIt<ClientsRepository>();

    return StreamBuilder<CustomerModel>(
      stream: repository.watchClient(customerId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('something_error'.tr()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator(size: 32));
        }

        final customer = snapshot.data;

        if (customer == null) {
          return Center(child: Text('something_error'.tr()));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(32.w),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'customer_details'.tr(),
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  HeightSpace(24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomerHeaderCard(
                          name: customer.name ?? '',
                          phone: customer.phone ?? '',
                          address: customer.address,
                          padding: 16,
                          width: 120,
                          height: 120,
                          width1: 80,
                          height1: 80,
                        ),
                      ),

                      SizedBox(width: 20.w),

                      Expanded(
                        child: CustomerDebtCard(
                          amount: customer.balance?.toString() ?? '0',
                          onPayDebt: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return BlocProvider(
                                  create: (_) => getIt<DebtCubit>(),
                                  child: DecreaseDebtDialog(
                                    clientId: customer.id!,
                                    currentBalance: customer.balance ?? 0,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  HeightSpace(32),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'recent_invoices'.tr(),
                          style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('show_all'.tr()),
                      ),
                    ],
                  ),

                  HeightSpace(12),

                  InvoiceList(invoices: customer.invoices),

                  HeightSpace(24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomerStatCard(
                          title: 'total_purchases'.tr(),
                          value: customer.totalPurchases.toString(),
                          icon: Icons.trending_up,
                        ),
                      ),

                      SizedBox(width: 20.w),

                      Expanded(
                        child: CustomerStatCard(
                          title: 'order_count'.tr(),
                          value: customer.orderCount.toString(),
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
