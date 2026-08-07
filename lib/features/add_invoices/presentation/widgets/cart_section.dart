import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'cart_item.dart';

class CartSection extends StatelessWidget {
  const CartSection({super.key});

  static const cartItems = [
    {'productName': 'Wooden Plank', 'unitPrice': 15.99, 'quantity': 2},
    {'productName': 'Metal Bracket', 'unitPrice': 8.50, 'quantity': 1},
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'cart'.tr(),
        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      HeightSpace(8),
      if (cartItems.isEmpty)
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Trigger add new product bottom sheet
            },
            icon: Icon(Icons.add, color: context.colors.primary),
            label: Text(
              'add_new_product'.tr(),
              style: TextStyle(color: context.colors.primary),
            ),
          ),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return Card(
              margin: EdgeInsets.only(
                bottom: index < cartItems.length - 1 ? 8 : 0,
              ),
              child: CartItem(
                productName: item['productName'] as String,
                unitPrice: item['unitPrice'] as double,
                quantity: item['quantity'] as int,
                onQuantityChanged: (newQty) {
                  // TODO: Update quantity
                },
                onDelete: () {
                  // TODO: Remove from cart
                },
              ),
            );
          },
        ),
    ],
  );
}
