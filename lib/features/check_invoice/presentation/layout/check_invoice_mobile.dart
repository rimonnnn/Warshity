import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/amount_and_price_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_information.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/finally_price.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/paid_and_remaining.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/print_and_share_invoice.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/thanks_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/top_check_invoice_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/total_price.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

class CheckInvoiceMobile extends StatelessWidget {
  const CheckInvoiceMobile({super.key, required this.invoice});

  final InvoiceModel invoice;

  Future<void> _printInvoice(BuildContext context) async {
    final pdfService = getIt<InvoicePdfService>();

    final data = InvoicePdfData.fromInvoice(invoice);

    final pdfBytes = await pdfService.generateInvoicePdf(
      data,
      context.locale,
      context.invoiceLabels,
    );

    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("check_invoice".tr(), style: context.text.headlineMedium),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppPadding.sm),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      HeightSpace(32),

                      TopCheckInvoiceWidget(),

                      HeightSpace(24),

                      Divider(
                        thickness: 1,
                        height: 20,
                        color: Colors.grey[400],
                      ),

                      HeightSpace(16),

                      CheckInvoiceInformation(invoiceModel: invoice),

                      HeightSpace(24),

                      AmountAndPriceWidget(items: invoice.items),

                      HeightSpace(40),  

                      Divider(
                        thickness: 1,
                        height: 20,
                        color: Colors.grey[400],
                      ),

                      HeightSpace(16),

                      TotalPrice(
                        subtotal: invoice.subtotal,
                        discount: invoice.discount,
                      ),

                      HeightSpace(16),

                      FinallyPrice(total: invoice.total),

                      HeightSpace(8),

                      PaidAndRemaining(
                        paidAmount: invoice.paidAmount,
                        remainingAmount: invoice.remainingAmount,
                      ),

                      HeightSpace(12),

                      ThanksWidget(),

                      HeightSpace(12),
                    ],
                  ),
                ),
              ),
            ),

            PrintAndShareInvoice(
              onSharePdf: () {},
              onPrint: () => _printInvoice(context),
            ),

            HeightSpace(22),
          ],
        ),
      ),
    );
  }
}

