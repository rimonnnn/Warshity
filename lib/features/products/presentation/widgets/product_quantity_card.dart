import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

import 'quantity_action_button.dart';

class ProductQuantityCard extends StatelessWidget {
  const ProductQuantityCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'current_quantity'.tr(),
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${product.quantity}',
                style: context.text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                product.unit,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              QuantityActionButton(
                icon: Icons.remove_rounded,
                onPressed: product.quantity > 0
                    ? () => context.read<ProductsCubit>().decreaseQuantity(
                        product.id,
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${product.quantity}',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              QuantityActionButton(
                icon: Icons.add_rounded,
                primary: true,
                onPressed: () =>
                    context.read<ProductsCubit>().increaseQuantity(product.id),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final cubit = context.read<ProductsCubit>();

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
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: Text('edit_quantity'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
