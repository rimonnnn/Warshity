import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';

class AmountAndPriceWidget extends StatelessWidget {
  const AmountAndPriceWidget({super.key, required this.items});

  final List<InvoiceItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.outlineVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("catagory".tr(), style: context.text.bodyLarge),
              Text("amount".tr(), style: context.text.bodyLarge),
              Text("the_price".tr(), style: context.text.bodyLarge),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: context.text.bodyMedium,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      item.quantity.toString(),
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      item.price.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: context.text.bodyMedium,
                    ),
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
