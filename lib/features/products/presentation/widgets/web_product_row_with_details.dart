import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

import 'web_product_utils.dart';
import 'web_product_widgets.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.product,
    required this.index,
    required this.compact,
    this.onTap,
  });

  final ProductModel product;
  final int index;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _tapArea({
    required Widget child,
    required VoidCallback? onTap,
    BorderRadius? borderRadius,
  }) {
    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _tapArea(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              child: Text('$index', style: textTheme.bodySmall),
            ),
          ),

          Expanded(
            flex: 4,
            child: _tapArea(
              onTap: onTap,
              child: Row(
                children: [
                  ProductImage(imageUrl: product.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: _tapArea(
              onTap: onTap,
              child: Text(
                product.barcode.isEmpty ? '-' : product.barcode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: _tapArea(
              onTap: onTap,
              child: CategoryBadge(category: product.category),
            ),
          ),

          Expanded(
            flex: 1,
            child: _tapArea(
              onTap: onTap,
              child: Text(
                product.unit.isEmpty ? '-' : product.unit,
                style: textTheme.bodySmall,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: _tapArea(
              onTap: onTap,
              child: Text(
                '${formatMoney(product.price)} ${'EGP'.tr()}',
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Expanded(flex: 2, child: _ProductQuantityControls(product: product)),

          SizedBox(width: 45, child: _DeleteButton(product: product, size: 21)),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: _tapArea(
              onTap: onTap,
              child: Row(
                children: [
                  ProductImage(imageUrl: product.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.barcode.isEmpty ? '-' : product.barcode,
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${formatMoney(product.price)} ${'EGP'.tr()}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          _ProductQuantityControls(product: product),

          _DeleteButton(product: product, size: 20),
        ],
      ),
    );
  }
}

class _ProductQuantityControls extends StatelessWidget {
  const _ProductQuantityControls({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();

    return QuantityControls(
      quantity: product.quantity,
      onDecrease: product.quantity > 0
          ? () => cubit.decreaseQuantity(product.id)
          : null,
      onIncrease: () => cubit.increaseQuantity(product.id),
      onEdit: () {
        QuantityBottomSheet.show(
          context: context,
          quantity: product.quantity,
          onQuantityChanged: (newQuantity) async {
            await cubit.updateQuantity(
              productId: product.id,
              quantity: newQuantity,
            );
          },
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.product, required this.size});

  final ProductModel product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'delete'.tr(),
      onPressed: () => deleteProduct(context, product),
      icon: Icon(Icons.delete_outline, color: context.colors.error, size: size),
    );
  }
}
