import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/search_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/cubit/home_cubit.dart';
import 'package:warshity/features/home/presentation/cubit/home_state.dart';
import 'package:warshity/features/home/presentation/widgets/card_widget.dart';
import 'package:warshity/features/home/presentation/widgets/container_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstackitem_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstockcard_widget.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_list.dart';
import 'package:warshity/features/home/presentation/widgets/section_header.dart';

class WebHome extends StatelessWidget {
  const WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('wershity'.tr()),
              const SizedBox(width: 24),
              CustomSearchTextField(
                width: 384,
                height: 36,
                hintText: 'search1'.tr(),
              ),
            ],
          ),
          centerTitle: true,
        ),
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
                'daily_sales'.tr(),
                Icons.trending_up_outlined,
                'EGP ${state.todaySales.toStringAsFixed(2)}',
              ),
              (
                'number_of_Invoices'.tr(),
                Icons.receipt_long_outlined,
                '${state.invoiceCount} ${'invoices'.tr()}',
              ),
              (
                'total_clients'.tr(),
                Icons.group_outlined,
                '${state.clientCount} ${'clients'.tr()}',
              ),
              (
                'total_products'.tr(),
                Icons.inventory_2_outlined,
                '${state.productCount} ${'products'.tr()}',
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ContainerWidget(height: 192, borderRadius: 12),

                    const HeightSpace(32),

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

                    const HeightSpace(32),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: LowStockCard(
                            title: 'warning'.tr(),
                            children: state.lowStockProducts
                                .map(
                                  (product) => LowStockItem(
                                    productName: product.name,
                                    remainText:
                                        '${product.quantity} ${product.unit}',
                                    onPressed: () {},
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              SectionHeader(
                                title: 'lastoperations'.tr(),
                                actionText: 'Show All'.tr(),
                                onActionPressed: () {
                                  context.pushNamed(AppRoutes.invoiceScreen);
                                },
                              ),

                              const SizedBox(height: 16),

                              RecentOperationList(
                                operations: state.recentInvoices.map((invoice) {
                                  final date = DateTime.tryParse(
                                    invoice.createdAt,
                                  );
                                  return RecentOperationModel(
                                    customerName: invoice.customerName,
                                    time: date != null
                                        ? DateFormat('hh:mm a').format(date)
                                        : '--:--',
                                    price: invoice.total.toStringAsFixed(2),
                                  );
                                }).toList(),
                                avatarSize: 22,
                                widthbetween: 10,
                                horzontalPadding: 16,
                                verticalPadding: 14,
                                borderRadius: 12,
                              ),
                            ],
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
