import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/AddProduct/presentation/layout/mobile_addproduct.dart';
import 'package:warshity/features/AddProduct/presentation/layout/web_addproduct.dart';

class AddproductScreen extends StatelessWidget {
  const AddproductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileAddproduct(), desktop: AddProductWeb()),
    );
  }
}
