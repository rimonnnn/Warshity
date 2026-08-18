import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/widgets/product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    super.key,
    required this.products,
    this.padding,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.onTap,
    this.onDelete,
    this.height,
    this.width,
  });

  final List<ProductModel> products;

  final EdgeInsetsGeometry? padding;

  final ScrollPhysics physics;

  final bool shrinkWrap;

  final void Function(int index)? onTap;

  final Future<void> Function(ProductModel product)? onDelete;

  final double? height;

  final double? width;

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete Product'.tr()),

          content: Text(
            'Are you sure you want to delete "${product.name}"?'.tr(),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancel'.tr()),
            ),

            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text('Delete'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (onDelete != null) {
      await onDelete!(product);
    }
  }

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

        return Stack(
          children: [
            ProductCard(
              productName: product.name,
              productCode: product.barcode,
              price: product.price,
              quantity: product.quantity,

              image: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported_outlined);
                      },
                    )
                  : null,

              onTap: () {
                onTap?.call(index);
              },

              width: width,

              height: height,
            ),

            if (onDelete != null)
              Positioned(
                left: 10.w,
                top: 10.h,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),

                    onTap: () {
                      _showDeleteConfirmation(context, product);
                    },

                    child: Container(
                      width: 34.w,
                      height: 34.w,

                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 19.sp,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
