import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
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

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          title: Text(
            'wershity'.tr(),
            style: context.text.titleLarge?.copyWith(
              color: context.colors.onSurface,
            ),
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
              padding: EdgeInsets.all(16.sp),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWidget(),

                    HeightSpace(32.h),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statistics.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        mainAxisExtent: 160.h,
                      ),
                      itemBuilder: (context, index) {
                        final item = statistics[index];

                        return CardWidget(
                          title: item.$1,
                          icon: item.$2,
                          value: item.$3,
                        );
                      },
                    ),

                    HeightSpace(32.h),

                    LowStockCard(
                      title: 'warning'.tr(),
                      children: state.lowStockProducts
                          .map(
                            (product) => LowStockItem(
                              productName: product.name,
                              remainText: '${product.quantity} ${product.unit}',
                              onPressed: () {},
                            ),
                          )
                          .toList(),
                    ),

                    HeightSpace(32.h),

                    SectionHeader(
                      title: 'lastoperations'.tr(),
                      actionText: 'Show All'.tr(),
                      onActionPressed: () {
                        context.pushNamed(AppRoutes.invoiceScreen);
                      },
                    ),

                    HeightSpace(16.h),

                    RecentOperationList(
                      operations: state.recentInvoices.map((invoice) {
                        final date = DateTime.tryParse(invoice.createdAt);

                        return RecentOperationModel(
                          customerName: invoice.customerName,
                          time: date != null
                              ? DateFormat('hh:mm a').format(date)
                              : '--:--',
                          price: invoice.total.toStringAsFixed(2),
                        );
                      }).toList(),
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
