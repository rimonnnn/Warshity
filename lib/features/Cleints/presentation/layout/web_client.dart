import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/customer_model.dart';
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

  int selectedIndex = 0;

  late final List<String> filters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    filters = ["all".tr(), "debt".tr(), "balanced".tr()];
  }

  final customers = [
    CustomerModel(
      name: "customer_ahmed".tr(),
      phone: "01012345678",
      balance: "1,400 ج.م",
      hasDebt: true,
      avatar: Icon(Icons.person, size: 90),
    ),
    CustomerModel(
      name: "customer_mohamed".tr(),
      phone: "01098765432",
      balance: "0 ج.م",
      hasDebt: false,
      avatar : Icon(Icons.person, size: 90),
    ),
    CustomerModel(
      name: "customer_ahmed".tr(),
      phone: "01012345678",
      balance: "1,400 ج.م",
      hasDebt: true,
      avatar: Icon(Icons.person, size: 90),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "customers".tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const Spacer(),

                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1),
                      label: Text("new_customer".tr()),
                    ),
                  ],
                ),

                HeightSpace(24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// القائمة
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          ProductSearchWidget(
                            controller: searchController,
                            hintText: "search_client".tr(),
                          ),

                          HeightSpace(20),

                          CustomerFilterTabs(
                            categories: filters,
                            selectedIndex: selectedIndex,
                            onSelected: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),

                          HeightSpace(20),

                          CustomerList(customers: customers, padding1: 16),
                        ],
                      ),
                    ),

                    WidthSpace(24),

                    /// الخريطة
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
