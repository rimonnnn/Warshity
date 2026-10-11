import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/productdetails/presentation/widgets/product_quantity_card.dart';

import 'product_price_formatter.dart';

class ProductHero extends StatelessWidget {
  const ProductHero({super.key, required this.product, required this.compact});

  final ProductModel product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageSize = compact ? 132.0 : 180.0;

    final image = Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl.isEmpty
          ? Icon(
              Icons.inventory_2_outlined,
              size: compact ? 50 : 64,
              color: colors.onSurfaceVariant,
            )
          : Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: compact ? 46 : 58,
                color: colors.onSurfaceVariant,
              ),
            ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
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
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          softWrap: true,
          style: (compact ? context.text.titleLarge : context.text.headlineMedium)
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          product.barcode.isEmpty ? '—' : product.barcode,
          textAlign: TextAlign.end,
          softWrap: true,
          style: context.text.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            Text(
              '${formatPrice(product.price)} ${'EGP'.tr()}',
              style: context.text.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: image),
                const SizedBox(height: 18),
                details,
                const SizedBox(height: 18),
                ProductQuantityCard(product: product, expanded: true),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 24),
                Expanded(child: details),
                const SizedBox(width: 24),
                ProductQuantityCard(product: product),
              ],
            ),
    );
  }
}
