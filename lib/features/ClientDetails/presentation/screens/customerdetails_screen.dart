import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/Cleints/data/model/customer_model.dart';
import 'package:warshity/features/ClientDetails/presentation/layout/mobile_customer_details.dart';
import 'package:warshity/features/ClientDetails/presentation/layout/web_customer_details.dart';

class CustomerdetailsScreen extends StatelessWidget {
  const CustomerdetailsScreen({
    super.key,
    required this.customer,
  });

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(
        mobile: MobileCustomerDetails(
          customer: customer,
        ),
        desktop: WebCustomerDetails(
          customer: customer,
        ),
      ),
    );
  }
}