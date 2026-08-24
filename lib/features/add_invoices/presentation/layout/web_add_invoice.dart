import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/add_product_dialog.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/bestselling_products.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_customer_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';

/// Web / desktop variant of the Add Invoice screen.
///
/// No internal breakpoint logic here — AppResponsive is responsible for
/// deciding when to mount this widget vs MobileAddInvoice. This keeps a
/// single LayoutBuilder in the tree (inside AppResponsive) and avoids the
/// nested-LayoutBuilder assertion issue.
class WebAddInvoice extends StatefulWidget {
  const WebAddInvoice({super.key});

  @override
  State<WebAddInvoice> createState() => _WebAddInvoiceState();
}

class _WebAddInvoiceState extends State<WebAddInvoice> {
  final TextEditingController discountController = TextEditingController();
   final searchController = TextEditingController();

  static const double _maxContentWidth = 1400;
  static const double _rightColumnWidth = 380;
  static const double _gap = 24;

  @override
  void dispose() {
    discountController.dispose();
    super.dispose();
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddClientDialog(),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddProductDialog(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'add_invoice'.tr(),
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      foregroundColor: context.colors.primary,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: search, best selling, cart
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InvoiceSearchBar(onAddProduct: _showAddProductDialog),
                    const SizedBox(height: _gap),
                    const BestSellingProducts(),
                    const SizedBox(height: _gap),
                    const CartSection(),
                  ],
                ),
              ),
              const SizedBox(width: _gap),
              // Right column: customer, discount, summary, create button
              SizedBox(
                width: _rightColumnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InvoiceCustomerCard(onTap: _showAddClientDialog, controller: searchController,),
                    const SizedBox(height: _gap),
                    CustomTextField(
                      label: 'discount'.tr(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIconData: Icons.percent,
                      onChanged: (value) {},
                      hint: 'enter_discount'.tr(),
                      controller: discountController,
                      validator: (value) => AppValidators.price(value),
                    ),
                    const SizedBox(height: _gap),
                    const InvoiceSummaryCard(
                      subtotal: 20,
                      discount: 20,
                      total: 20,
                    ),
                    const SizedBox(height: _gap),
                    CreateInvoiceButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.checkInvoiceScreen);
                      },
                      fontSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
