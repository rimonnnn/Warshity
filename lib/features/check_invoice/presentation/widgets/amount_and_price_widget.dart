import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';

class AmountAndPriceWidget extends StatelessWidget {
  const AmountAndPriceWidget({super.key, required this.items});

  final List<InvoiceItemModel> items;

  Widget _headerCell(
    BuildContext context,
    String text, {
    required int flex,
    TextAlign align = TextAlign.center,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _textCell(
    BuildContext context,
    String text, {
    required int flex,
    TextAlign align = TextAlign.center,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _quantityCell(BuildContext context, int quantity) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            quantity.toString(),
            maxLines: 1,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _headerCell(
            context,
            'catagory'.tr(),
            flex: 5,
            align: TextAlign.start,
          ),
          _headerCell(context, 'amount'.tr(), flex: 2),
          _headerCell(context, 'the_price'.tr(), flex: 3, align: TextAlign.end),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, InvoiceItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          // Product name
          _textCell(context, item.productName, flex: 5, align: TextAlign.start),

          // Quantity
          _quantityCell(context, item.quantity),

          // Price
          _textCell(
            context,
            item.price.toStringAsFixed(2),
            flex: 3,
            align: TextAlign.end,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Table header
          _buildHeader(context),

          // Product rows
          for (var index = 0; index < items.length; index++) ...[
            _buildItemRow(context, items[index]),

            if (index < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
