import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

import 'product_price_formatter.dart';
import 'product_quantity_card.dart';

class ProductHero extends StatelessWidget {
  const ProductHero({super.key, required this.product, required this.compact});

  final ProductModel product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final image = Container(
      width: compact ? 130 : 180,
      height: compact ? 130 : 180,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl.isEmpty
          ? Icon(
              Icons.inventory_2_outlined,
              size: compact ? 52 : 64,
              color: colors.onSurfaceVariant,
            )
          : Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  size: compact ? 48 : 58,
                  color: colors.onSurfaceVariant,
                );
              },
            ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            product.category.isEmpty ? '-' : product.category,
            style: context.text.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: context.text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.barcode.isEmpty ? '—' : product.barcode,
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${formatPrice(product.price)} ${'EGP'.tr()}',
              style: context.text.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: product.quantity > 0 ? colors.primary : colors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              product.quantity > 0 ? 'in_stock'.tr() : 'out_of_stock'.tr(),
              style: context.text.bodySmall?.copyWith(
                color: product.quantity > 0 ? colors.primary : colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.center, child: image),
                const SizedBox(height: 20),
                details,
              ],
            )
          : Row(
              children: [
                image,
                const SizedBox(width: 28),
                Expanded(child: details),
                const SizedBox(width: 24),
                ProductQuantityCard(product: product),
              ],
            ),
    );
  }
}
