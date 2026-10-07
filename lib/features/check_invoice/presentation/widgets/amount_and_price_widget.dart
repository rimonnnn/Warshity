import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';

class AmountAndPriceWidget extends StatelessWidget {
  const AmountAndPriceWidget({super.key, required this.items});

  final List<InvoiceItemModel> items;

  Widget _headerText(
    BuildContext context,
    String text, {
    TextAlign align = TextAlign.center,
  }) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align == TextAlign.start
            ? AlignmentDirectional.centerStart
            : align == TextAlign.end
            ? AlignmentDirectional.centerEnd
            : Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          textAlign: align,
          style: context.text.bodyLarge,
        ),
      ),
    );
  }

  Widget _itemText(
    BuildContext context,
    String text, {
    TextAlign align = TextAlign.center,
    FontWeight? fontWeight,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align == TextAlign.start
              ? AlignmentDirectional.centerStart
              : align == TextAlign.end
              ? AlignmentDirectional.centerEnd
              : Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: context.text.bodyMedium?.copyWith(fontWeight: fontWeight),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.outlineVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _headerText(context, 'catagory'.tr(), align: TextAlign.start),
              const SizedBox(width: 8),
              _headerText(context, 'amount'.tr()),
              const SizedBox(width: 8),
              _headerText(context, 'the_price'.tr(), align: TextAlign.end),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _itemText(context, item.productName, align: TextAlign.start),

                  const SizedBox(width: 8),

                  _itemText(context, item.quantity.toString()),

                  const SizedBox(width: 8),

                  _itemText(
                    context,
                    item.price.toStringAsFixed(2),
                    align: TextAlign.end,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
