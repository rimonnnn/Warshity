import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/features/products/data/product_model.dart';
import 'package:warshity/features/products/presentation/widgets/product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    super.key,
    required this.products,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.onTap, this.height, this.width,
  });

  final List<ProductModel> products;

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  final void Function(int index)? onTap;
final double? height;
final double? width;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          productName: product.name,
          productCode: product.code,
          price: product.price,
          quantity: product.quantity,
          icon: product.icon,
          image: product.image,
          onTap: () => onTap?.call(index),
          width: width,
          height: height,

        );
      },
    );
  }
}