import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/customer_model.dart';
import 'package:warshity/features/Cleints/presentation/widgets/add_customer_button.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_filter_tabs.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_list.dart';
import 'package:warshity/features/Cleints/presentation/widgets/customer_map_card.dart';
import 'package:warshity/features/Cleints/presentation/widgets/delivery_orders_card.dart';
import 'package:warshity/features/products/presentation/widgets/product_search_widget.dart';

class MobileClient extends StatefulWidget {
  const MobileClient({super.key});

  @override
  State<MobileClient> createState() => _MobileCustomersState();
}

class _MobileCustomersState extends State<MobileClient> {
  final searchController = TextEditingController();

  int selectedIndex = 0;

  late final List<String> filters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    filters = [
      "all".tr(),
      "debt".tr(),
      "balanced".tr(),
    ];
  }

  final customers = [
    CustomerModel(
      name: "customer_ahmed".tr(),
      phone: "01012345678",
      balance: "1,400 ج.م",
      hasDebt: true,
      avatar: Icon(
        Icons.person,
        size: 48.sp,
      )
    ),
    CustomerModel(
      name: "customer_mohamed".tr(),
      phone: "01098765432",
      balance: "0 ج.م",
      hasDebt: false,
      avatar: Icon(
        Icons.person,
        size: 48.sp,)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("customers".tr()),
      ),

      floatingActionButton: AddCustomerButton(
        onPressed: () {
          
          context.pushNamed(AppRoutes.addclientScreen);
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductSearchWidget(
                controller: searchController,
                hintText: "search_client".tr(),
              ),

              HeightSpace(20.h),

              CustomerFilterTabs(
                categories: filters,
                selectedIndex: selectedIndex,
                onSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),

              HeightSpace(20.h),

              CustomerList(
                customers: customers,
              ),

              HeightSpace(24.h),

              CustomerMapCard(
                image: Image.asset(
                  AppAssets.map,
                  fit: BoxFit.cover,
                ),
              ),

              HeightSpace(20.h),

              DeliveryOrdersCard(
                ordersCount: 3,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}