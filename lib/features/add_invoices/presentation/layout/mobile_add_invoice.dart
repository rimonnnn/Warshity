import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/bestselling_products.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_section.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/create_invoice_button.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_customer_card.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';

class MobileAddInvoice extends StatefulWidget {
  const MobileAddInvoice({super.key});

  @override
  State<MobileAddInvoice> createState() => _MobileAddInvoiceState();
}

class _MobileAddInvoiceState extends State<MobileAddInvoice> {
  final TextEditingController discountController = TextEditingController();

  @override
  void dispose() {
    discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          'add_invoice'.tr(),
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      foregroundColor: context.colors.primary,
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeightSpace(4),
                // Customer Section
                InvoiceCustomerCard(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => const AddClientDialog(),
                    );
                  },
                ),

                // Search Product
                InvoiceSearchBar(
                  onAddProduct: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => BlocProvider(
                        create: (context) => getIt<AddClientCubit>(),
                        child: const AddClientDialog(),
                      ),
                    );
                  },
                ),
                HeightSpace(16),

                // Best Selling Products
                const BestSellingProducts(),
                HeightSpace(16),

                // Shopping Cart
                const CartSection(),
                HeightSpace(16),
                CustomTextField(
                  label: "discount".tr(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIconData: Icons.percent,
                  onChanged: (value) {},
                  hint: 'enter_discount'.tr(),
                  controller: discountController,
                  validator: (value) => AppValidators.price(value),
                ),
                HeightSpace(16),
                // Invoice Summary
                const InvoiceSummaryCard(subtotal: 20, discount: 20, total: 20),

                HeightSpace(16),

                // Bottom Button
                CreateInvoiceButton(
                  onPressed: () {
                    context.pushNamed(AppRoutes.checkInvoiceScreen);
                  },
                  fontSize: 20.sp,
                ),
                HeightSpace(24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
