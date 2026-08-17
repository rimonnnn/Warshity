import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/ClientDetails/presentation/layout/mobile_customer_details.dart';
import 'package:warshity/features/ClientDetails/presentation/layout/web_customer_details.dart';

class CustomerdetailsScreen extends StatelessWidget {
  const CustomerdetailsScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MobileCustomerDetails(
        customerId: customerId,
      ),
      desktop: WebCustomerDetails(
        customerId: customerId,
      ),
    );
  }
}