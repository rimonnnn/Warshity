import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/cubit/home_cubit.dart';
import 'package:warshity/features/home/presentation/cubit/home_state.dart';
import 'package:warshity/features/home/presentation/widgets/card_widget.dart';
import 'package:warshity/features/home/presentation/widgets/container_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstackitem_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstockcard_widget.dart';
import 'package:warshity/features/home/presentation/widgets/quick_action_model.dart';
import 'package:warshity/features/home/presentation/widgets/quick_actions_web.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/widgets/section_header.dart';
import 'package:warshity/features/home/presentation/widgets/weekly_sales_chart_web.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

class WebHome extends StatelessWidget {
  const WebHome({super.key});

  @override
  Widget build(BuildContext context) {
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

            // الترتيب زي الصورة: المبيعات - الفواتير - المنتجات - العملاء
            final statistics = [
              (
                'daily_sales'.tr(),
                Icons.trending_up_outlined,
                'EGP ${state.todaySales.toStringAsFixed(2)}',
              ),
              (
                'number_of_Invoices'.tr(),
                Icons.receipt_long_outlined,
                '${state.invoiceCount} ${'invoice'.tr()}',
              ),
              (
                'total_products'.tr(),
                Icons.inventory_2_outlined,
                '${state.productCount} ${'product'.tr()}',
              ),
              (
                'total_clients'.tr(),
                Icons.group_outlined,
                '${state.clientCount} ${'client'.tr()}',
              ),
            ];

            final quickActions = [
              QuickActionModel(
                title: 'quick_new_invoice'.tr(),
                subtitle: 'quick_new_invoice_sub'.tr(),
                icon: Icons.note_add_outlined,
                onTap: () {
                  // TODO: context.pushNamed(AppRoutes.xxx);
                },
              ),
              QuickActionModel(
                title: 'quick_add_product'.tr(),
                subtitle: 'quick_add_product_sub'.tr(),
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  // TODO: context.pushNamed(AppRoutes.xxx);
                },
              ),
              QuickActionModel(
                title: 'quick_add_client'.tr(),
                subtitle: 'quick_add_client_sub'.tr(),
                icon: Icons.person_add_alt_1_outlined,
                onTap: () {
                  // TODO: context.pushNamed(AppRoutes.xxx);
                },
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // Welcome Banner
                    // =========================
                    ContainerWidget(height: 120, borderRadius: 12),

                    const HeightSpace(24),

                    // =========================
                    // Statistics
                    // =========================
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

                        return CardWidget(
                          width: 222,
                          height: 130,
                          borderRadius: 12,
                          heightspace: 10,
                          padding: 16,
                          iconSize: 15,
                          color: context.colors.surfaceContainerLow,
                          onTap: () {},
                          title: item.$1,
                          icon: item.$2,
                          value: item.$3,
                        );
                      },
                    ),

                    const HeightSpace(24),

                    // =========================
                    // Low Stock (full width)
                    // =========================
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
                                      await context
                                          .read<ProductsCubit>()
                                          .updateQuantity(
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

                    // =========================
                    // Recent Operations + Side Column
                    // =========================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // Recent Operations + Weekly Chart
                        // =========================
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

                        // =========================
                        // Side Column
                        // =========================
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
