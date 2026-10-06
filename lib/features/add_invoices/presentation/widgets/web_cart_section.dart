import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_state.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/add_product_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_item.dart';

import 'web_form_widgets.dart';
import 'web_misc_widgets.dart';

class WebCartSection extends StatelessWidget {
  const WebCartSection({super.key, required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<ProductSearchCubit>();

    return WebSectionCard(
      title: 'cart'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: WebSearchField(
                  hint: 'search_products'.tr(),
                  onChanged: searchCubit.searchProducts,
                  icon: Icons.search,
                ),
              ),
              const SizedBox(width: 12),
              AddProductButton(onTap: onAddProduct),
            ],
          ),
          const SizedBox(height: 12),
          const _ProductSearchResults(),
          const SizedBox(height: 16),
          const _CartItemsList(),
        ],
      ),
    );
  }
}

class _ProductSearchResults extends StatelessWidget {
  const _ProductSearchResults();

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<ProductSearchCubit>();
    final invoiceCubit = context.read<InvoiceCubit>();

    return BlocBuilder<ProductSearchCubit, ProductSearchState>(
      builder: (context, state) {
        if (state is ProductSearchLoading) {
          return const WebSearchStatus(child: CircularProgressIndicator());
        }

        if (state is ProductSearchError) {
          return WebSearchStatus(child: Text(state.message));
        }

        if (state is! ProductSearchSuccess) {
          return const SizedBox.shrink();
        }

        if (state.products.isEmpty) {
          return WebSearchStatus(child: Text('no_products_found'.tr()));
        }

        return WebSearchResultCard(
          children: state.products.map<Widget>((product) {
            return ListTile(
              dense: true,
              leading: const CircleAvatar(
                child: Icon(Icons.inventory_2_outlined),
              ),
              title: Text(product.name),
              subtitle: Text('${product.price} - ${product.barcode}'),
              onTap: () {
                invoiceCubit.addProduct(product);
                searchCubit.clearSearch();
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList();

  void _changeQuantity(
    InvoiceCubit cubit,
    dynamic item,
    int newQuantity,
  ) {
    if (newQuantity <= 0) {
      cubit.removeProduct(item.productId);
      return;
    }

    if (newQuantity > item.quantity) {
      for (var i = item.quantity; i < newQuantity; i++) {
        cubit.increaseQuantity(item.productId);
      }
      return;
    }

    if (newQuantity < item.quantity) {
      for (var i = item.quantity; i > newQuantity; i--) {
        cubit.decreaseQuantity(item.productId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceCubit = context.read<InvoiceCubit>();

    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) {
          return WebEmptyCart(text: 'cart'.tr());
        }

        return Column(
          children: state.cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CartItem(
                productName: item.productName,
                unitPrice: item.price,
                quantity: item.quantity,
                onQuantityChanged: (q) => _changeQuantity(invoiceCubit, item, q),
                onDelete: () => invoiceCubit.removeProduct(item.productId),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
