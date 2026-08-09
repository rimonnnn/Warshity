import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/amount_and_price_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_information.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/finally_price.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/paid_and_remaining.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/thanks_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/top_check_invoice_widget.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/total_price.dart';

class CheckInvoiceWeb extends StatelessWidget {
  const CheckInvoiceWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("check_invoice".tr(), style: context.text.headlineMedium),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الشريط الجانبي: زراير الطباعة والمشاركة رأسي
          Container(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: context.colors.onPrimary,
              border: Border(
                right: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                _VerticalActionButton(
                  icon: Icons.print_outlined,
                  label: "print".tr(),
                  onTap: () {
                    // TODO: نفس منطق الطباعة اللي في PrintAndShareInvoice
                  },
                ),
                const HeightSpace(16),
                _VerticalActionButton(
                  icon: Icons.share_outlined,
                  label: "share_pdf".tr(),
                  onTap: () {
                    // TODO: نفس منطق المشاركة اللي في PrintAndShareInvoice
                  },
                ),
              ],
            ),
          ),

          // المحتوى: الفاتورة كلها تحت بعض جوه scroll واحد
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppPadding.sm),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const HeightSpace(24),
                          const TopCheckInvoiceWidget(),
                          const HeightSpace(24),
                          Divider(
                            thickness: 1,
                            height: 20,
                            color: Colors.grey[400],
                          ),
                          const HeightSpace(16),
                          const CheckInvoiceInformation(),
                          const HeightSpace(24),
                          const AmountAndPriceWidget(),
                          const HeightSpace(40),
                          Divider(
                            thickness: 1,
                            height: 20,
                            color: Colors.grey[400],
                          ),
                          const HeightSpace(16),
                          const TotalPrice(),
                          const HeightSpace(16),
                          const FinallyPrice(),
                          const HeightSpace(8),
                          const PaidAndRemaining(),
                          const HeightSpace(12),
                          const ThanksWidget(),
                          const HeightSpace(24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalActionButton extends StatelessWidget {
  const _VerticalActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: context.colors.primary),
            const HeightSpace(4),
            Text(label, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
