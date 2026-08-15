import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/styling/app_assets.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/loading_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';
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

  List<String> get filters => ["all".tr(), "debt".tr(), "balanced".tr()];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   filters = ["all".tr(), "debt".tr(), "balanced".tr()];
  // }

  // final customers = [
  //   CustomerModel(
  //     name: "customer_ahmed".tr(),
  //     phone: "01012345678",
  //     balance: "1,400 ${"pound".tr()}",
  //     hasDebt: true,

  //     // avatar: Icon(
  //     //   Icons.person,
  //     //   size: 48.sp,
  //     // ),
  //     invoices: [
  //       InvoiceModel(
  //         invoiceNumber: "INV-001",
  //         customerName: "customer_ahmed".tr(),
  //         date: "12 ${"month3".tr()} 2024",
  //         paymentMethod: "unpaid".tr(),
  //         itemCount: 3,
  //         totalPrice: "450 ${"pound".tr()}",
  //       ),
  //       InvoiceModel(
  //         invoiceNumber: "INV-002",
  //         customerName: "customer_ahmed".tr(),
  //         date: "05 ${"month3".tr()} 2024",
  //         paymentMethod: "paid".tr(),
  //         itemCount: 2,
  //         totalPrice: "950 ${"pound".tr()}",
  //       ),
  //       InvoiceModel(
  //         invoiceNumber: "INV-003",
  //         customerName: "customer_ahmed".tr(),
  //         date: "28 ${"month2".tr()} 2024",
  //         paymentMethod: "unpaid".tr(),
  //         itemCount: 4,
  //         totalPrice: "950 ${"pound".tr()}",
  //       ),
  //     ],

  //     totalPurchases: 12500 ,
  //     orderCount: 24,
  //   ),

  //   CustomerModel(
  //     name: "customer_mohamed".tr(),
  //     phone: "01098765432",
  //     balance: "0 ${"pound".tr()}",
  //     hasDebt: false,

  //     // avatar: Icon(
  //     //   Icons.person,
  //     //   size: 48.sp,
  //     // ),
  //     invoices: [
  //       InvoiceModel(
  //         invoiceNumber: "INV-004",
  //         customerName: "customer_mohamed".tr(),
  //         date: "20 ${"month3".tr()} 2024",
  //         paymentMethod: "paid".tr(),
  //         itemCount: 5,
  //         totalPrice: "1,200 ${"pound".tr()}",
  //       ),
  //       InvoiceModel(
  //         invoiceNumber: "INV-005",
  //         customerName: "customer_mohamed".tr(),
  //         date: "10 ${"month3".tr()} 2024",
  //         paymentMethod: "paid".tr(),
  //         itemCount: 2,
  //         totalPrice: "750 ${"pound".tr()}",
  //       ),
  //     ],

  //     totalPurchases: 8500,
  //     orderCount: 15,
  //   ),
  // ];

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

              BlocBuilder<ClientsCubit, ClientsState>(
                builder: (BuildContext context, state) {
                  if (state is ClientsLoading) {
                    return LoadingWidget(message: "Loading Clients...".tr());
                  }
                  if (state is ClientsLoaded) {
                    return CustomerList(
                      customers: state.clients,
                      onTap: (index) {
                        context.pushNamed(
                          AppRoutes.customerdetailsScreen,
                          extra: state.clients[index],
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
    );
  }
}
