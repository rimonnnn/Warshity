import 'dart:typed_data';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';
import 'package:warshity/features/check_invoice/data/invoice_actions_service.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/share_options_sheet.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

import '../widgets/web_cart_section.dart';
import '../widgets/web_create_invoice_button.dart';
import '../widgets/web_customer_section.dart';
import '../widgets/web_discount_section.dart';
import '../widgets/web_invoice_preview.dart';

part '../widgets/web_add_invoice_actions.dart';

class WebAddInvoice extends StatefulWidget {
  const WebAddInvoice({super.key});

  @override
  State<WebAddInvoice> createState() => _WebAddInvoiceState();
}

class _WebAddInvoiceState extends State<WebAddInvoice>
    with _WebAddInvoiceActions {
  final TextEditingController discountController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();

  late final CustomerSearchCubit customerSearchCubit = CustomerSearchCubit(
    getIt<ClientsRepository>(),
  );

  late final ProductSearchCubit productSearchCubit = ProductSearchCubit(
    getIt<ProductsRepository>(),
  );

  @override
  late final InvoiceCubit invoiceCubit = getIt<InvoiceCubit>();

  final String _previewInvoiceId =
      'INV-${DateTime.now().millisecondsSinceEpoch}';
  final String _previewCreatedAt = DateTime.now().toIso8601String();

  @override
  void dispose() {
    discountController.dispose();
    paidAmountController.dispose();
    customerSearchCubit.close();
    productSearchCubit.close();
    invoiceCubit.close();
    super.dispose();
  }

  InvoiceModel _buildPreviewInvoice(InvoiceState state) {
    final ready = _readyInvoice;

    return InvoiceModel(
      invoiceId: ready?.invoiceId ?? _previewInvoiceId,
      customerId: ready?.customerId ?? state.selectedCustomerId ?? '',
      customerName: ready?.customerName ?? state.selectedCustomerName ?? '',
      createdAt: ready?.createdAt ?? _previewCreatedAt,
      items: state.cartItems,
      subtotal: state.subtotal,
      discount: state.discount,
      total: state.total,
      paidAmount: state.paidAmount,
      remainingAmount: state.remainingAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: customerSearchCubit),
        BlocProvider.value(value: productSearchCubit),
        BlocProvider.value(value: invoiceCubit),
      ],
      child: Scaffold(
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
        body: Directionality(
          textDirection: context.locale.languageCode == 'ar'
              ? .rtl
              : .ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1480),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 1000;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildEditor(),
                          const SizedBox(height: 20),
                          _buildPreview(),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildEditor()),
                        const SizedBox(width: 24),
                        SizedBox(width: 470, child: _buildPreview()),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebCustomerSection(onAddClient: _showAddClientDialog),
        const SizedBox(height: 16),
        WebCartSection(onAddProduct: _showAddProductDialog),
        const SizedBox(height: 16),
        WebDiscountSection(
          discountController: discountController,
          paidAmountController: paidAmountController,
        ),
        const SizedBox(height: 16),
        BlocBuilder<InvoiceCubit, InvoiceState>(
          builder: (_, state) {
            return InvoiceSummaryCard(
              subtotal: state.subtotal,
              discount: state.discount,
              total: state.total,
            );
          },
        ),
        const SizedBox(height: 16),
        BlocListener<InvoiceCubit, InvoiceState>(
          listener: _onInvoiceStateChanged,
          child: WebCreateInvoiceButton(onPressed: _createInvoice),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return WebInvoicePreview(
          invoice: _buildPreviewInvoice(state),
          previewKey: _invoicePreviewKey,
          canUseActions: _canUseInvoiceActions,
          invoiceSaved: _invoiceSaved,
          onShare: _openShareSheet,
          onPrint: _printInvoice,
        );
      },
    );
  }
}
