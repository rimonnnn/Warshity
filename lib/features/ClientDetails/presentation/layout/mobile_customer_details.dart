import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_debt_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_header_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_stat_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_list.dart';

class MobileCustomerDetails extends StatelessWidget {
  const MobileCustomerDetails({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("customer_details".tr())),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerHeaderCard(
                name: customer.name,
                phone: customer.phone.toString(),
                address: customer.address,
              ),

              HeightSpace(16.h),

              CustomerDebtCard(
                amount: customer.balance.toString(),
                onPayDebt: () {},
              ),

              HeightSpace(20.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "recent_invoices".tr(),
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(onPressed: () {}, child: Text("show_all".tr())),
                ],
              ),

              HeightSpace(12.h),

              InvoiceList(invoices: customer.invoices),

              HeightSpace(20.h),

              Row(
                children: [
                  CustomerStatCard(
                    title: "total_purchases".tr(),
                    value: customer.totalPurchases.toString(),
                    icon: Icons.trending_up,
                  ),

                  SizedBox(width: 12.w),

                  CustomerStatCard(
                    title: "order_count".tr(),
                    value: customer.orderCount.toString(),
                    icon: Icons.shopping_bag_outlined,
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
