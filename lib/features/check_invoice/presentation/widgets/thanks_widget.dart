import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ThanksWidget extends StatelessWidget {
  const ThanksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "thank_you_for_your_business".tr(),
      style: context.text.bodyLarge!.copyWith(color: const Color(0xFF6F4627)),
    );
  }
}
