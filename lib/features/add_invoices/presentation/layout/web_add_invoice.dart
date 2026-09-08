import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';

import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_state.dart';

import 'package:warshity/features/add_invoices/presentation/widgets/bestselling_products.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_customer_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';

import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

class WebAddInvoice extends StatefulWidget {
  const WebAddInvoice({super.key});

  @override
  State<WebAddInvoice> createState() => _WebAddInvoiceState();
}

class _WebAddInvoiceState extends State<WebAddInvoice> {
  final TextEditingController discountController = TextEditingController();

  static const double _maxContentWidth = 1400;
  static const double _rightColumnWidth = 380;
  static const double _gap = 24;

  late final CustomerSearchCubit customerSearchCubit = CustomerSearchCubit(
    getIt<ClientsRepository>(),
  );

  late final ProductSearchCubit productSearchCubit = ProductSearchCubit(
    getIt<ProductsRepository>(),
  );

  late final InvoiceCubit invoiceCubit = getIt<InvoiceCubit>();

  CategoriesCubit get categoriesCubit => context.read<CategoriesCubit>();

  @override
  void dispose() {
    discountController.dispose();
    customerSearchCubit.close();
    productSearchCubit.close();
    invoiceCubit.close();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider(
        create: (_) => getIt<AddClientCubit>(),
        child: const AddClientDialog(),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: categoriesCubit),
          BlocProvider(create: (_) => getIt<AddProductCubit>()),
        ],
        child: const AddProductDialog(),
      ),
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

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InvoiceSearchBar(
                          onSearchChanged: productSearchCubit.searchProducts,
                          onAddProduct: _showAddProductDialog,
                        ),

                        BlocBuilder<ProductSearchCubit, ProductSearchState>(
                          builder: (context, state) {
                            if (state is ProductSearchLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is ProductSearchError) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(state.message),
                              );
                            }

                            if (state is! ProductSearchSuccess) {
                              return const SizedBox.shrink();
                            }

                            if (state.products.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('no_products_found'.tr()),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.products.length,
                              itemBuilder: (_, index) {
                                final product = state.products[index];

                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.inventory_2_outlined),
                                    ),
                                    title: Text(product.name),
                                    subtitle: Text(
                                      '${product.price} - ${product.barcode}',
                                    ),
                                    onTap: () {
                                      invoiceCubit.addProduct(product);
                                      productSearchCubit.clearSearch();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: _gap),

                        const BestSellingProducts(),

                        const SizedBox(height: _gap),

                        const CartSection(),
                      ],
                    ),
                  ),

                  const SizedBox(width: _gap),

                  SizedBox(
                    width: _rightColumnWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BlocBuilder<InvoiceCubit, InvoiceState>(
                          builder: (context, state) {
                            return InvoiceCustomerCard(
                              selectedCustomerName: state.selectedCustomerName,
                              onSearchChanged:
                                  customerSearchCubit.searchClients,
                              onClearCustomer: () {
                                invoiceCubit.removeCustomer();
                                customerSearchCubit.clearSearch();
                              },
                              onTap: _showAddClientDialog,
                            );
                          },
                        ),

                        BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
                          builder: (context, state) {
                            if (state is CustomerSearchLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is CustomerSearchError) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(state.message),
                              );
                            }

                            if (state is! CustomerSearchSuccess) {
                              return const SizedBox.shrink();
                            }

                            if (state.clients.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('no_clients_found'.tr()),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.clients.length,
                              itemBuilder: (_, index) {
                                final client = state.clients[index];

                                return Card(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(client.name ?? ''),
                                    subtitle: client.phone?.isNotEmpty == true
                                        ? Text(client.phone!)
                                        : null,
                                    onTap: () {
                                      if (client.id == null ||
                                          client.name == null) {
                                        return;
                                      }

                                      invoiceCubit.selectCustomer(
                                        customerId: client.id!,
                                        customerName: client.name!,
                                      );

                                      customerSearchCubit.clearSearch();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: _gap),

                        CustomTextField(
                          label: 'discount'.tr(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIconData: Icons.percent,
                          onChanged: (value) {
                            invoiceCubit.updateDiscount(
                              double.tryParse(value) ?? 0,
                            );
                          },
                          hint: 'enter_discount'.tr(),
                          controller: discountController,
                          validator: AppValidators.price,
                        ),

                        const SizedBox(height: _gap),

                        BlocBuilder<InvoiceCubit, InvoiceState>(
                          builder: (_, state) {
                            return InvoiceSummaryCard(
                              subtotal: state.subtotal,
                              discount: state.subtotal * state.discount / 100,
                              total: state.total,
                            );
                          },
                        ),

                        const SizedBox(height: _gap),

                        BlocConsumer<InvoiceCubit, InvoiceState>(
                          listener: (context, state) {
                            if (state is InvoiceError) {
                              showAnimatedSnackDialog(
                                context,
                                message: state.message.replaceFirst('Exception: ', ''),
                                type: AnimatedSnackBarType.error,
                              );
                            }

                            if (state is InvoiceSuccess) {


                              context.pushNamed(
                                AppRoutes.checkInvoiceScreen,
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is InvoiceLoading;

                            return CreateInvoiceButton(
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (state.selectedCustomerId == null) {
                                        _showMessage(
                                          'please_select_customer'.tr(),
                                          error: true,
                                        );
                                        return;
                                      }

                                      if (state.cartItems.isEmpty) {
                                        _showMessage(
                                          'please_add_product'.tr(),
                                          error: true,
                                        );
                                        return;
                                      }

                                      invoiceCubit.createInvoice();
                                    },
                              fontSize: 20,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}