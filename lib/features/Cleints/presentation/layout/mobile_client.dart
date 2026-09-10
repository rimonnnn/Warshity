import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/remove_clients_state.dart';
import 'package:warshity/features/Cleints/presentation/widgets/add_customer_button.dart';
import 'package:warshity/features/Cleints/presentation/widgets/clients_shimmer.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_filter_tabs.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_list.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_map_card.dart';
import 'package:warshity/features/Cleints/presentation/widgets/delivery_orders_card.dart';
import 'package:warshity/features/Cleints/presentation/widgets/remove_client_dialog.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';

class MobileClient extends StatefulWidget {
  const MobileClient({super.key});

  @override
  State<MobileClient> createState() => _MobileCustomersState();
}

class _MobileCustomersState extends State<MobileClient> {
  final searchController = TextEditingController();

  List<String> get filters => ["all".tr(), "debt".tr(), "balanced".tr()];

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("customers".tr())),

      floatingActionButton: AddCustomerButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => BlocProvider(
              create: (context) => getIt<AddClientCubit>(),
              child: const AddClientDialog(),
            ),
          );
        },
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductSearchWidget(
                  controller: searchController,
                  hintText: 'search_client'.tr(),
                  onChanged: (query) {
                    context.read<ClientsCubit>().searchClients(query);
                  },
                ),

                HeightSpace(20.h),

                BlocSelector<ClientsCubit, ClientsState, ClientFilter>(
                  selector: (state) {
                    if (state is ClientsLoaded) {
                      return state.filter;
                    }

                    return ClientFilter.all;
                  },
                  builder: (context, currentFilter) {
                    return CustomerFilterTabs(
                      categories: filters,
                      selectedIndex: switch (currentFilter) {
                        ClientFilter.all => 0,
                        ClientFilter.hasDebt => 1,
                        ClientFilter.noDebt => 2,
                      },
                      onSelected: (index) {
                        final filter = switch (index) {
                          0 => ClientFilter.all,
                          1 => ClientFilter.hasDebt,
                          2 => ClientFilter.noDebt,
                          _ => ClientFilter.all,
                        };

                        context.read<ClientsCubit>().filterClients(filter);
                      },
                    );
                  },
                ),

                HeightSpace(20.h),

                BlocBuilder<ClientsCubit, ClientsState>(
                  builder: (BuildContext context, state) {
                    if (state is ClientsLoading) {
                      return ClientShimmer();
                    }
                    if (state is ClientsLoaded) {
                      return CustomerList(
                        customers: state.displayedClients,

                        onTap: (index) {
                          context.pushNamed(
                            AppRoutes.customerdetailsScreen,
                            extra: state.displayedClients[index].id,
                          );
                        },
                        onDelete: (index) {
                          final customer = state.displayedClients[index];
                          if (customer.id == null) {
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (_) {
                              return BlocProvider(
                                create: (_) => getIt<RemoveClientCubit>(),
                                child: RemoveClientDialog(
                                  clientId: customer.id!,
                                  clientName: customer.name ?? '',
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    if (state is ClientsError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),

                HeightSpace(24.h),

                CustomerMapCard(
                  image: Image.asset(AppAssets.map, fit: BoxFit.cover),
                ),

                HeightSpace(20.h),

                DeliveryOrdersCard(ordersCount: 3, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
