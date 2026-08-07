import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class ProductPriceFields extends StatelessWidget {
  const ProductPriceFields({
    super.key,
    this.sellingPriceController,
    this.purchasePriceController, this.widthspace,
  });

  final TextEditingController? sellingPriceController;
  final TextEditingController? purchasePriceController;
final double? widthspace;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: sellingPriceController,
            label: "selling_price".tr(),
            hint: "0.00",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            width: double.infinity,
          ),
        ),

        WidthSpace(widthspace ?? 16.w),

        Expanded(
          child: CustomTextField(
            controller: purchasePriceController,
            label: "purchase_price".tr(),
            hint: "0.00",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}
