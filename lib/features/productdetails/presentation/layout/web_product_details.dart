import 'package:flutter/material.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_details_content.dart';


class WebProductDetails extends StatelessWidget {
  const WebProductDetails({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ProductDetailsContent(productId: productId);
  }
}
