import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/amount_and_price_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_information.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/finally_price.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/paid_and_remaining.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/print_and_share_invoice.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/thanks_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/top_check_invoice_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/total_price.dart';

class CheckInvoiceMobile extends StatelessWidget {
  const CheckInvoiceMobile({super.key});

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
                      CheckInvoiceInformation(),
                      HeightSpace(24),
                      AmountAndPriceWidget(),
                      HeightSpace(40),
                      Divider(
                        thickness: 1,
                        height: 20,
                        color: Colors.grey[400],
                      ),
                      HeightSpace(16),
                      TotalPrice(),
                      HeightSpace(16),
                      FinallyPrice(),
                      HeightSpace(8),
                      PaidAndRemaining(),
                      HeightSpace(12),
                      ThanksWidget(),
                      HeightSpace(12),
                    ],
                  ),
                ),
              ),
            ),
            PrintAndShareInvoice(),
            HeightSpace(22),
          ],
        ),
      ),
    );
  }
}
