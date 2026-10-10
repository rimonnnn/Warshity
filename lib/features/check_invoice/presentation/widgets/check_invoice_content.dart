import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/amount_and_price_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_information.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/developer_credit_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/paid_and_remaining.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/thanks_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/top_check_invoice_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/total_price.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

/// The full visual layout of an invoice — header, items, totals, footer.
///
/// This is the exact widget captured by the RepaintBoundary when sharing
/// as an image, and also used for on-screen preview. Keeping it as its
/// own widget (rather than inline in the page) means it can be reused by
/// CheckInvoiceWeb and tested/previewed on its own.
class CheckInvoiceContent extends StatelessWidget {
  const CheckInvoiceContent({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      decoration: BoxDecoration(
        // surfaceContainer: نفس لون إطار الصفحة اللي حواليه (كانت surface)
        // ومهم هنا لأن الـ RepaintBoundary بيلتقط الخلفية دي في صورة التصدير
        color: scheme.surfaceContainer,
        // AppRadius.md بدل AppPadding.sm: ثابت padding كان مستخدم كـ radius
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          const TopCheckInvoiceWidget(),

          HeightSpace(16),

          // outlineVariant بدل Colors.grey[400]
          Divider(thickness: 1, height: 20, color: scheme.outlineVariant),

          HeightSpace(16),

          CheckInvoiceInformation(invoiceModel: invoice),

          HeightSpace(24),

          AmountAndPriceWidget(items: invoice.items),

          // 24 بدل 40: الفراغ الكبير بعد الأصناف كان بيبعد الإجماليات عنها
          HeightSpace(24),

          Divider(thickness: 1, height: 20, color: scheme.outlineVariant),

          HeightSpace(16),

          TotalPrice(subtotal: invoice.subtotal, discount: invoice.discount),

          // HeightSpace(16),

          // FinallyPrice(total: invoice.total),
          HeightSpace(8),

          PaidAndRemaining(
            paidAmount: invoice.paidAmount,
            remainingAmount: invoice.remainingAmount,
          ),

          HeightSpace(12),

          const ThanksWidget(),

          const DeveloperCreditWidget(),

          HeightSpace(12),
        ],
      ),
    );
  }
}
