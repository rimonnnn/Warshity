import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/loading_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_filter_tabs.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_list.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_map_card.dart';
import 'package:warshity/features/Cleints/presentation/widgets/delivery_orders_card.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';

class WebCustomers extends StatefulWidget {
  const WebCustomers({super.key});

  @override
  State<WebCustomers> createState() => _WebCustomersState();
}

class _WebCustomersState extends State<WebCustomers> {
  final searchController = TextEditingController();

  List<String> get filters => ['all'.tr(), 'debt'.tr(), 'balanced'.tr()];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'customers'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const Spacer(),

                    FilledButton.icon(
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
                      icon: const Icon(Icons.person_add_alt_1),
                      label: Text('new_customer'.tr()),
                    ),
                  ],
                ),

                HeightSpace(24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ProductSearchWidget(
                            controller: searchController,
                            hintText: 'search_client'.tr(),
                            onChanged: (query) {
                              context.read<ClientsCubit>().searchClients(query);
                            },
                          ),

                          HeightSpace(20),

                          BlocSelector<
                            ClientsCubit,
                            ClientsState,
                            ClientFilter
                          >(
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

                                  context.read<ClientsCubit>().filterClients(
                                    filter,
                                  );
                                },
                              );
                            },
                          ),

                          HeightSpace(20),

                          BlocBuilder<ClientsCubit, ClientsState>(
                            builder: (context, state) {
                              if (state is ClientsLoading) {
                                return LoadingWidget(
                                  message: 'Loading Clients...'.tr(),
                                );
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
                                );
                              }

                              if (state is ClientsError) {
                                return Center(child: Text(state.message));
                              }

                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),

                    WidthSpace(24),

                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          CustomerMapCard(
                            height: 260,
                            image: Image.asset(
                              AppAssets.map,
                              fit: BoxFit.cover,
                            ),
                          ),

                          HeightSpace(20),

                          DeliveryOrdersCard(ordersCount: 3, onTap: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
