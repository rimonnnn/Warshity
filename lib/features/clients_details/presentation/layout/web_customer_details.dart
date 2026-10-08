import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/app_loading_indicator.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/debt_cubit.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_debt_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/decrease_debt_dialog.dart';
import 'package:warshity/features/clients_details/presentation/widgets/invoice_list.dart';

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
          return _buildError(context);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator(size: 32));
        }

        final customer = snapshot.data;

        if (customer == null) {
          return _buildError(context);
        }

        return ColoredBox(
          color: context.colors.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildContent(
                      context,
                      customer,
                      constraints.maxWidth,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    CustomerModel customer,
    double availableWidth,
  ) {
    final isCompact = availableWidth < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(context),

        SizedBox(height: 24.h),

        _buildOverviewSection(context, customer, isCompact: isCompact),

        SizedBox(height: 28.h),

        _buildInvoicesSection(context, customer),

        SizedBox(height: 28.h),

        _buildStatsSection(context, customer, isCompact: isCompact),
      ],
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Text(
      'customer_details'.tr(),
      style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    CustomerModel customer, {
    required bool isCompact,
  }) {
    final headerCard = CustomerHeaderCard(
      name: customer.name ?? '',
      phone: customer.phone ?? '',
      address: customer.address,
    );

    final debtCard = CustomerDebtCard(
      amount: customer.balance?.toString() ?? '0',
      onPayDebt: () => _openDecreaseDebtDialog(context, customer),
    );

    if (isCompact) {
      return Column(
        children: [
          headerCard,
          SizedBox(height: 16.h),
          debtCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: headerCard),
        SizedBox(width: 16.w),
        Expanded(flex: 2, child: debtCard),
      ],
    );
  }

  Widget _buildInvoicesSection(BuildContext context, CustomerModel customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_invoices'.tr(),
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),

        SizedBox(height: 14.h),

        InvoiceList(customerId: customer.id ?? customerId),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    CustomerModel customer, {
    required bool isCompact,
  }) {
    final totalPurchasesCard = CustomerStatCard(
      title: 'total_purchases'.tr(),
      value: customer.totalPurchases.toString(),
      icon: Icons.trending_up_outlined,
    );

    final orderCountCard = CustomerStatCard(
      title: 'order_count'.tr(),
      value: customer.orderCount.toString(),
      icon: Icons.shopping_bag_outlined,
    );

    if (isCompact) {
      return Column(
        children: [
          totalPurchasesCard,
          SizedBox(height: 12.h),
          orderCountCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: totalPurchasesCard),
        SizedBox(width: 16.w),
        Expanded(child: orderCountCard),
      ],
    );
  }

  void _openDecreaseDebtDialog(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider(
          create: (_) => getIt<DebtCubit>(),
          child: DecreaseDebtDialog(
            clientId: customer.id ?? customerId,
            currentBalance: customer.balance ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Text('something_error'.tr(), style: context.text.bodyLarge),
    );
  }
}
