import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddCustomerButton extends StatelessWidget {
  const AddCustomerButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.person_add_alt_1),
      label: Text(
        "new_customer".tr(),
      ),
    );
  }
}