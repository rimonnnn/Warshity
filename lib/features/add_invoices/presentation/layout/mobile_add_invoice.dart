import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/customer_search_state.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/product_search_state.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_customer_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

class MobileAddInvoice extends StatefulWidget {
  const MobileAddInvoice({super.key});

  @override
  State<MobileAddInvoice> createState() => _MobileAddInvoiceState();
}

class _MobileAddInvoiceState extends State<MobileAddInvoice> {
  final discountController = TextEditingController();
  final paidAmountController = TextEditingController();

  late final customerSearchCubit = CustomerSearchCubit(
    getIt<ClientsRepository>(),
  );

  late final productSearchCubit = ProductSearchCubit(
    getIt<ProductsRepository>(),
  );

  late final invoiceCubit = getIt<InvoiceCubit>();

  CategoriesCubit get categoriesCubit => context.read<CategoriesCubit>();

  @override
  void dispose() {
    discountController.dispose();
    paidAmountController.dispose();
    customerSearchCubit.close();
    productSearchCubit.close();
    invoiceCubit.close();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    final scheme = context.colors;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          // onError فوق الأحمر، بدل Colors.red بنص افتراضي
          style: error ? TextStyle(color: scheme.onError) : null,
        ),
        backgroundColor: error ? scheme.error : null,
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
          title: Text(
            'add_invoice'.tr(),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          foregroundColor: context.colors.primary,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              // الكيبورد بيتقفل لما المستخدم يسحب الصفحة
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeightSpace(4),

                  BlocBuilder<InvoiceCubit, InvoiceState>(
                    builder: (context, state) {
                      return InvoiceCustomerCard(
                        selectedCustomerName: state.selectedCustomerName,
                        onSearchChanged: customerSearchCubit.searchClients,
                        onClearCustomer: () {
                          invoiceCubit.removeCustomer();
                          customerSearchCubit.clearSearch();
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider(
                              create: (_) => getIt<AddClientCubit>(),
                              child: const AddClientDialog(),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
                    builder: (context, state) {
                      final scheme = context.colors;

                      if (state is CustomerSearchLoading) {
                        return const _ResultsLoading();
                      }

                      if (state is CustomerSearchError) {
                        return _ResultsMessage(
                          text: state.message,
                          isError: true,
                        );
                      }

                      if (state is! CustomerSearchSuccess) {
                        return const SizedBox.shrink();
                      }

                      if (state.clients.isEmpty) {
                        return _ResultsMessage(text: 'no_clients_found'.tr());
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: state.clients.length,
                        itemBuilder: (_, index) {
                          final client = state.clients[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.primary,
                                child: const Icon(Icons.person),
                              ),
                              title: Text(
                                client.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: client.phone?.isNotEmpty == true
                                  ? Text(
                                      client.phone!,
                                      style: context.text.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                              // أيقونة الإضافة توضح إن الضغط على الصف بيختار العميل
                              trailing: Icon(
                                Icons.add_circle_outline,
                                color: scheme.primary,
                              ),
                              onTap: () {
                                if (client.id == null || client.name == null) {
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

                  InvoiceSearchBar(
                    onSearchChanged: productSearchCubit.searchProducts,
                    onAddProduct: () {
                      showDialog(
                        context: context,
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: categoriesCubit),
                            BlocProvider(
                              create: (_) => getIt<AddProductCubit>(),
                            ),
                          ],
                          child: const AddProductDialog(),
                        ),
                      );
                    },
                  ),

                  BlocBuilder<ProductSearchCubit, ProductSearchState>(
                    builder: (context, state) {
                      final scheme = context.colors;

                      if (state is ProductSearchLoading) {
                        return const _ResultsLoading();
                      }

                      if (state is ProductSearchError) {
                        return _ResultsMessage(
                          text: state.message,
                          isError: true,
                        );
                      }

                      if (state is! ProductSearchSuccess) {
                        return const SizedBox.shrink();
                      }

                      if (state.products.isEmpty) {
                        return _ResultsMessage(text: 'no_products_found'.tr());
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: state.products.length,
                        itemBuilder: (_, index) {
                          final product = state.products[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              // صورة المنتج لو موجودة، وإلا أيقونة (AppImage بيتعامل مع الاتنين)
                              leading: CircleAvatar(
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.primary,
                                child: const Icon(Icons.inventory_2_outlined),
                              ),
                              title: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${product.price} - ${product.barcode}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: Icon(
                                Icons.add_circle_outline,
                                color: scheme.primary,
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

                  HeightSpace(16),

                  const CartSection(),

                  HeightSpace(16),

                  CustomTextField(
                    label: 'discount'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIconData: Icons.discount_outlined,

                    onChanged: (value) {
                      invoiceCubit.updateDiscount(double.tryParse(value) ?? 0);
                    },
                    hint: 'enter_discount'.tr(),
                    controller: discountController,
                    validator: AppValidators.price,
                  ),
                  HeightSpace(16),
                  CustomTextField(
                    label: 'paid_amount'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIconData: Icons.attach_money_outlined,

                    onChanged: (value) {
                      invoiceCubit.updatePaidAmount(
                        double.tryParse(value) ?? 0,
                      );
                    },
                    hint: 'enter_paid_amount'.tr(),
                    controller: paidAmountController,
                    validator: AppValidators.price,
                  ),

                  HeightSpace(16),

                  BlocBuilder<InvoiceCubit, InvoiceState>(
                    builder: (_, state) {
                      return InvoiceSummaryCard(
                        subtotal: state.subtotal,
                        discount: state.discount,
                        total: state.total,
                      );
                    },
                  ),

                  HeightSpace(24),
                ],
              ),
            ),
          ),
        ),

        // زر إنشاء الفاتورة ثابت تحت الشاشة: كان في آخر الـ scroll،
        // فالمستخدم لازم ينزل لآخر الصفحة كل مرة. نفس الـ BlocConsumer ونفس الشروط بالظبط.
        bottomNavigationBar: BlocConsumer<InvoiceCubit, InvoiceState>(
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
                extra: state.invoice,
              );
            }
          },
          builder: (context, state) {
            final scheme = context.colors;
            final isLoading = state is InvoiceLoading;

            // لما الكيبورد يفتح الشريط بيختفي، عشان ماياخدش مساحة من الحقول
            final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
            if (keyboardOpen) return const SizedBox.shrink();

            return DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: CreateInvoiceButton(
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
                          _showMessage('please_add_product'.tr(), error: true);
                          return;
                        }

                        invoiceCubit.createInvoice();
                      },
                fontSize: 20.sp,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultsLoading extends StatelessWidget {
  const _ResultsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _ResultsMessage extends StatelessWidget {
  const _ResultsMessage({required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: isError ? scheme.error : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
