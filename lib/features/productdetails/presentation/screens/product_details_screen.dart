import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/productdetails/presentation/layout/mobile_product_details.dart';
import 'package:warshity/features/productdetails/presentation/layout/web_product_details.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return AppResponsive(
      mobile: MobileProductDetails(productId: productId),
      desktop: WebProductDetails(productId: productId),
    );
  }
}
