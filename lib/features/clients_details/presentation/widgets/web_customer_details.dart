import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/app_loading_indicator.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/debt_cubit.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_balance_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_error_view.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_bar.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_invoices_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_profile_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stats_section.dart';
import 'package:warshity/features/clients_details/presentation/widgets/decrease_debt_dialog.dart';

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
          return const CustomerErrorView();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator(size: 32));
        }

        final customer = snapshot.data;

        if (customer == null) {
          return const CustomerErrorView();
        }

        return ColoredBox(
          color: context.colors.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 700 ? 16 : 28,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1380),
                    child: _buildPage(context, customer, width: width),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    CustomerModel customer, {
    required double width,
  }) {
    final isMobile = width < 760;
    final gap = width < 1000 ? 16.0 : 20.0;

    final header = CustomerProfileCard(customer: customer);
    final debt = CustomerBalanceCard(
      balance: customer.balance ?? 0,
      onPay: () => _openDecreaseDebtDialog(context, customer),
    );
    final stats = CustomerStatsSection(customer: customer);
    final invoices = CustomerInvoicesCard(
      customer: customer,
      fallbackCustomerId: customerId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CustomerHeaderBar(),
        const SizedBox(height: 16),
        header,
        const SizedBox(height: 20),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              debt,
              const SizedBox(height: 16),
              stats,
              const SizedBox(height: 20),
              invoices,
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: invoices),
              SizedBox(width: gap),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [debt, const SizedBox(height: 16), stats],
                ),
              ),
            ],
          ),
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
}
