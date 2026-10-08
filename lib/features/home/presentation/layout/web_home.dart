import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/cubit/home_cubit.dart';
import 'package:warshity/features/home/presentation/cubit/home_state.dart';
import 'package:warshity/features/home/presentation/widgets/container_widget.dart';
import 'package:warshity/features/home/presentation/widgets/dashboard_statistics.dart';
import 'package:warshity/features/home/presentation/widgets/lowstackitem_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstockcard_widget.dart';
import 'package:warshity/features/home/presentation/widgets/quick_action_model.dart';
import 'package:warshity/features/home/presentation/widgets/quick_actions_web.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/widgets/section_header.dart';
import 'package:warshity/features/home/presentation/widgets/weekly_sales_chart_web.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

class WebHome extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const WebHome({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final productsCubit = context.read<ProductsCubit>();
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: Scaffold(
        backgroundColor: context.colors.surface,

        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is! HomeLoaded) {
              return const SizedBox.shrink();
            }

            final statistics = [
              (
                title: 'daily_sales'.tr(),
                icon: Icons.trending_up_outlined,
                value: 'EGP ${state.todaySales.toStringAsFixed(2)}',
                destination: 0,
              ),
              (
                title: 'number_of_Invoices'.tr(),
                icon: Icons.receipt_long_outlined,
                value: '${state.invoiceCount} ${'invoice'.tr()}',
                destination: 1,
              ),
              (
                title: 'total_products'.tr(),
                icon: Icons.inventory_2_outlined,
                value: '${state.productCount} ${'product'.tr()}',
                destination: 2,
              ),
              (
                title: 'total_clients'.tr(),
                icon: Icons.group_outlined,
                value: '${state.clientCount} ${'client'.tr()}',
                destination: 3,
              ),
            ];

            final quickActions = [
              QuickActionModel(
                title: 'quick_new_invoice'.tr(),
                subtitle: 'quick_new_invoice_sub'.tr(),
                icon: Icons.note_add_outlined,
                onTap: () {
                  context.pushNamed(AppRoutes.addInvoicesScreen);
                },
              ),
              QuickActionModel(
                title: 'quick_add_product'.tr(),
                subtitle: 'quick_add_product_sub'.tr(),
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => getIt<CategoriesCubit>()),
                        BlocProvider(create: (_) => getIt<AddProductCubit>()),
                      ],
                      child: const AddProductDialog(),
                    ),
                  );
                },
              ),
              QuickActionModel(
                title: 'quick_add_client'.tr(),
                subtitle: 'quick_add_client_sub'.tr(),
                icon: Icons.person_add_alt_1_outlined,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<AddClientCubit>(),
                      child: const AddClientDialog(),
                    ),
                  );
                },
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWidget(height: 120, borderRadius: 12),

                    const HeightSpace(24),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statistics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 130,
                          ),
                      itemBuilder: (context, index) {
                        final item = statistics[index];

                        return DashBoardStatistics(
                          width: 222,
                          height: 130,
                          borderRadius: 12,
                          heightspace: 10,
                          padding: 22,
                          iconSize: 30,
                          color: context.colors.surfaceContainerLow,
                          onTap: () => onNavigate?.call(item.destination),
                          title: item.title,
                          icon: item.icon,
                          value: item.value,
                        );
                      },
                    ),

                    const HeightSpace(24),

                    if (state.lowStockProducts.isNotEmpty) ...[
                      LowStockCard(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        title: 'warning'.tr(),
                        children: state.lowStockProducts
                            .map(
                              (product) => LowStockItem(
                                productName: product.name,
                                remainText:
                                    '${product.quantity} ${product.unit}',
                                onPressed: () {
                                  QuantityBottomSheet.show(
                                    context: context,
                                    quantity: product.quantity,
                                    onQuantityChanged: (newQuantity) async {
                                      await productsCubit.updateQuantity(
                                        productId: product.id,
                                        quantity: newQuantity,
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),

                      const HeightSpace(24),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: 'lastoperations'.tr(),
                                actionText: 'Show All'.tr(),
                                onActionPressed: () {
                                  context.pushNamed(AppRoutes.invoiceScreen);
                                },
                              ),

                              const HeightSpace(16),

                              RecentOperationsTableWeb(
                                operations: state.recentInvoices.map((invoice) {
                                  return RecentOperationModel(
                                    customerName: invoice.customerName,
                                    time: context
                                        .read<HomeCubit>()
                                        .formatInvoiceDate(invoice.createdAt),
                                    price: invoice.total.toStringAsFixed(2),
                                  );
                                }).toList(),
                              ),

                              const HeightSpace(24),

                              WeeklySalesChartWeb(values: state.weeklySales),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [QuickActionsWeb(actions: quickActions)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
