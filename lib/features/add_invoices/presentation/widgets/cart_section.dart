import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';

import 'cart_item.dart';

class CartSection extends StatelessWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        final cartItems = state.cartItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'cart'.tr(),
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            HeightSpace(8),

            if (cartItems.isNotEmpty)
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
                      productName: item.productName,
                      unitPrice: item.price,
                      quantity: item.quantity,

                      // تغيير الكمية
                      onQuantityChanged: (newQty) {
                        final cubit = context.read<InvoiceCubit>();

                        if (newQty <= 0) {
                          cubit.removeProduct(item.productId);
                        } else if (newQty > item.quantity) {
                          for (
                            int i = item.quantity;
                            i < newQty;
                            i++
                          ) {
                            cubit.increaseQuantity(
                              item.productId,
                            );
                          }
                        } else if (newQty < item.quantity) {
                          for (
                            int i = item.quantity;
                            i > newQty;
                            i--
                          ) {
                            cubit.decreaseQuantity(
                              item.productId,
                            );
                          }
                        }
                      },

                      // حذف المنتج
                      onDelete: () {
                        context.read<InvoiceCubit>().removeProduct(
                          item.productId,
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}