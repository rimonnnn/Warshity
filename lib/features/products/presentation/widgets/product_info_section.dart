import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

import 'info_item.dart';

class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: colors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'product_information'.tr(),
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 760;

              final items = [
                InfoItem(label: 'product_name'.tr(), value: product.name),
                InfoItem(
                  label: 'product_code'.tr(),
                  value: product.barcode.isEmpty ? '—' : product.barcode,
                ),
                InfoItem(
                  label: 'category'.tr(),
                  value: product.category.isEmpty ? '—' : product.category,
                ),
                InfoItem(
                  label: 'unit'.tr(),
                  value: product.unit.isEmpty ? '—' : product.unit,
                ),
              ];

              if (!twoColumns) {
                return Column(
                  children: [
                    for (final item in items) ...[
                      item,
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        items[0],
                        const SizedBox(height: 16),
                        items[2],
                      ],
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      children: [
                        items[1],
                        const SizedBox(height: 16),
                        items[3],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
