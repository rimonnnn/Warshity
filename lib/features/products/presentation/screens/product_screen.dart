import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/products/presentation/layout/mobile_product.dart';
import 'package:warshity/features/products/presentation/layout/web_product.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsive(mobile: MobileProduct(), desktop: WebProduct()),
    );
  }
}
