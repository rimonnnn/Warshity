import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/core/helper/app_validators.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';

import 'web_form_widgets.dart';

class WebDiscountSection extends StatelessWidget {
  const WebDiscountSection({
    super.key,
    required this.discountController,
    required this.paidAmountController,
  });

  final TextEditingController discountController;
  final TextEditingController paidAmountController;

  @override
  Widget build(BuildContext context) {
    final invoiceCubit = context.read<InvoiceCubit>();

    return WebSectionCard(
      title: 'discount'.tr(),
      child: Column(
        children: [
          WebInputField(
            label: 'discount'.tr(),
            hint: 'enter_discount'.tr(),
            controller: discountController,
            icon: Icons.discount_outlined,
            validator: AppValidators.price,
            onChanged: (value) {
              invoiceCubit.updateDiscount(double.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 16),
          WebInputField(
            label: 'paid_amount'.tr(),
            hint: 'enter_paid_amount'.tr(),
            controller: paidAmountController,
            icon: Icons.attach_money_outlined,
            validator: AppValidators.price,
            onChanged: (value) {
              invoiceCubit.updatePaidAmount(double.tryParse(value) ?? 0);
            },
          ),
        ],
      ),
    );
  }
}
