import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_filter_chips.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_list.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_search_bar.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_statistics_section.dart';

class InvoiceMobile extends StatelessWidget {
  const InvoiceMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'invoice_history'.tr(),
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              const InvoiceSearchBar(),
              HeightSpace(8),
              const InvoiceStatisticsSection(),
              HeightSpace(8),
              const InvoiceFilterChips(),
              HeightSpace(24),
              const Expanded(child: InvoiceList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(AppRoutes.addInvoicesScreen);
        },
        backgroundColor: context.colors.primaryContainer,
        foregroundColor: context.colors.onPrimaryContainer,
        child: Icon(Icons.add, size: 28.sp),
      ),
    );
  }
}
