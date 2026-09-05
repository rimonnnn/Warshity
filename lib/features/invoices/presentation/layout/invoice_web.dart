import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_filter_chips.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_list.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_search_bar.dart';

class InvoiceWeb extends StatelessWidget {
  const InvoiceWeb({super.key});

  @override  
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: screenWidth,
      child: Container(
        color: context.colors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: العنوان + زرار "إضافة فاتورة" بجانبه (بديل الـ FAB بتاع الموبايل)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'invoice_history'.tr(),
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IntrinsicWidth(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed(AppRoutes.addInvoicesScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(
                        'add_invoice'.tr(),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              InvoiceSearchBar(),
              SizedBox(height: 24),
              InvoiceFilterChips(),

              const SizedBox(height: 24),

              Expanded(child: InvoiceList()),
            ],
          ),
        ),
      ),
    );
  }
}
