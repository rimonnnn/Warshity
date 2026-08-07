import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/Cleints/presentation/layout/mobile_client.dart';
import 'package:warshity/features/Cleints/presentation/layout/web_client.dart';

class CleintsScreen extends StatelessWidget {
  const CleintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileClient(), desktop: WebCustomers()),
    );
  }
}
