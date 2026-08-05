import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/home/data/recent_operation_model.dart';
import 'package:warshity/features/home/presentation/widgets/card_widget.dart';
import 'package:warshity/features/home/presentation/widgets/container_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstackitem_widget.dart';
import 'package:warshity/features/home/presentation/widgets/lowstockcard_widget.dart';
import 'package:warshity/features/home/presentation/widgets/recent_operation_list.dart';
import 'package:warshity/features/home/presentation/widgets/section_header.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              ContainerWidget(),
              HeightSpace(32.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: titles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  mainAxisExtent: 160.h,
                ),
                itemBuilder: (context, index) => CardWidget(
                  title: titles[index],
                  icon: icons[index],
                  value: values[index],
                ),
              ),
              HeightSpace(32.h),
              LowStockCard(
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
              HeightSpace(32.h),
              SectionHeader(
                title: "lastoperations".tr(),
                actionText: "Show All".tr(),
                onActionPressed: () {},
              ),
              HeightSpace(16.h),

              RecentOperationList(
                operations: [
                  RecentOperationModel(
                    customerName: "customer_name".tr(),
                    time: "time".tr(),
                    price: "price".tr(),
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
