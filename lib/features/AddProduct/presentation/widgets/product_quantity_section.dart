import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

class ProductQuantitySection extends StatelessWidget {
  const ProductQuantitySection({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: "quantity1".tr(),
      hint: "0",
      keyboardType: TextInputType.number,
      width: double.infinity,
    );
  }
}