import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_debt_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_header_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/customer_stat_card.dart';
import 'package:warshity/features/ClientDetails/presentation/widgets/invoice_list.dart';

class WebCustomerDetails extends StatelessWidget {
  const WebCustomerDetails({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "customer_details".tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              HeightSpace(24),

              // Customer + Debt
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomerHeaderCard(
                      name: customer.name,
                      phone: customer.phone.toString(),
                      // avatar: customer.avatar,
                      padding: 16,
                      width: 120,
                      height: 120,
                      width1: 80,
                      height1: 80,
                    ),
                  ),

                  SizedBox(width: 20),

                  Expanded(
                    child: CustomerDebtCard(
                      amount: customer.balance.toString(),
                      onPayDebt: () {},
                    ),
                  ),
                ],
              ),

              HeightSpace(32),

              // Invoice title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "recent_invoices".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(onPressed: () {}, child: Text("show_all".tr())),
                ],
              ),

              HeightSpace(12),

              // Invoices
              InvoiceList(invoices: customer.invoices),

              HeightSpace(24),

              // Statistics
              Row(
                children: [
                  CustomerStatCard(
                    title: "total_purchases".tr(),
                    value: customer.totalPurchases.toString(),
                    icon: Icons.trending_up,
                  ),

                  SizedBox(width: 20),

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
