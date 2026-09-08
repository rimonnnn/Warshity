import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
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
    bool isDeleting = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Product'.tr()),

              content: isDeleting
                  ? SizedBox(
                      height: 80.h,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 28.w,
                              height: 28.w,
                              child: const CircularProgressIndicator(),
                            ),

                            SizedBox(height: 12.h),

                            Text('Deleting...'.tr()),
                          ],
                        ),
                      ),
                    )
                  : Text(
                      '${"Are you sure you want to delete".tr()} '
                      '${product.name}?',
                    ),

              actions: isDeleting
                  ? []
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: Text('Cancel'.tr()),
                      ),

                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),

                        onPressed: () async {
                          if (onDelete == null) {
                            return;
                          }

                          setState(() {
                            isDeleting = true;
                          });

                          try {
                            await onDelete!(product);

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop(true);
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setState(() {
                              isDeleting = false;
                            });

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete product'.tr()),
                              ),
                            );
                          }
                        },

                        child: Text('Delete'.tr()),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,

      physics: physics,

      shrinkWrap: shrinkWrap,

      itemCount: products.length,

      separatorBuilder: (_, __) {
        return SizedBox(height: 12.h);
      },

      itemBuilder: (context, index) {
        final product = products[index];

        return Stack(
          children: [
            ProductCard(
              productName: product.name,

              productCode: product.barcode,

              price: product.price,

              quantity: product.quantity,
               onIncrease: () {
    context.read<ProductsCubit>().increaseQuantity(
      product.id,
    );
  },

  onDecrease: () {
    context.read<ProductsCubit>().decreaseQuantity(
      product.id,
    );
  },

  onQuantityChanged: (quantity) {
    return context.read<ProductsCubit>().updateQuantity(
      productId: product.id,
      quantity: quantity,
    );
  },

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
                left: context.locale.languageCode == "ar" ? 320.w : 10.w,

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
