import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/search_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/widgets/card_widget.dart';
import 'package:warshity/features/home/presentation/widgets/container_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstackitem_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstockcard_widget.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_list.dart';
import 'package:warshity/features/home/presentation/widgets/section_header.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  List<String> titles = [
    "daily_sales".tr(),
    "number_of_Invoices".tr(),
    "total_clients".tr(),
    "total_products".tr(),
  ];
  List<IconData> icons = [
    Icons.trending_up_outlined,
    Icons.receipt_long_outlined,
    Icons.group_outlined,
    Icons.inventory_2_outlined,
  ];
  List<String> values = [
    "number_of_daily_sales".tr(),
    "numbervalue_of_Invoices".tr(),
    "number_of_clients".tr(),
    "totalvalue_of_products".tr(),
  ];
  final operations = [
    RecentOperationModel(
      customerName: "customer_mohamed_samir".tr(),
      time: "since_15_minutes".tr(),
      price: "price_450".tr(),
    ),
    RecentOperationModel(
      customerName: "customer_ahmed_ali".tr(),
      time: "since_30_minutes".tr(),
      price: "price_650".tr(),
    ),
    RecentOperationModel(
      customerName: "customer_mahmoud_hassan".tr(),
      time: "since_1_hour".tr(),
      price: "price_820".tr(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("wershity".tr()),
            SizedBox(width: 24),
            CustomSearchTextField(
              width: 384,
              height: 36,
              hintText: "search1".tr(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .end,
            children: [
              ContainerWidget(height: 192, borderRadius: 12),
              HeightSpace(32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 130,
                ),
                itemBuilder: (context, index) => CardWidget(
                  width: 222,
                  borderRadius: 12,
                  color: context.colors.surfaceContainerLow,
                  height: 130,
                  heightspace: 10,
                  onTap: () {},
                  title: titles[index],
                  icon: icons[index],
                  value: values[index],
                  iconSize: 15,
                  padding: 16,
                ),
              ),
              HeightSpace(32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: LowStockCard(
                      title: "warning".tr(),
                      children: [
                        LowStockItem(
                          productName: "wood".tr(),
                          remainText: "woodamount".tr(),
                          onPressed: () {},
                        ),
                        LowStockItem(
                          productName: "joinery".tr(),
                          remainText: "joineryamount".tr(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 24),

                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        SectionHeader(
                          title: "lastoperations".tr(),
                          actionText: "Show All".tr(),
                          onActionPressed: () {},
                        ),

                        SizedBox(height: 16),

                        RecentOperationList(
                          operations: operations,
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
      ),
    );
  }
}
