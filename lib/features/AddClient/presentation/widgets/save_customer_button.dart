import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SaveCustomerButton extends StatelessWidget {
  const SaveCustomerButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(
          "save_customer".tr(),
        ),
      ),
    );
  }
}