import 'package:flutter/material.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_details_content.dart';

/// Mobile entry point for the same product details components used on web.
class MobileProductDetails extends StatelessWidget {
  const MobileProductDetails({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return ProductDetailsContent(
      productId: productId,
      forceCompactLayout: true,
    );
  }
}
