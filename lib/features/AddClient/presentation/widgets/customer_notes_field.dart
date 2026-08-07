import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

class CustomerNotesField extends StatelessWidget {
  const CustomerNotesField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: "notes".tr(),
      hint: "notes_hint".tr(),
      width: double.infinity,
      height: 120,
    );
  }
}