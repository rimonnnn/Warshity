import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/AddClient/presentation/layout/mobile_addclient.dart';
import 'package:warshity/features/AddClient/presentation/layout/web_addclient.dart';

class AddclientScreen extends StatelessWidget {
  const AddclientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileAddclient(), desktop: AddCustomerWeb()),
    );
  }
}
