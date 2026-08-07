import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SaveProductButton extends StatelessWidget {
  const SaveProductButton({
    super.key,
    this.onPressed,
    this.width = double.infinity,
    this.height = 50,
  });

  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(
          "save_product".tr(),
        ),
      ),
    );
  }
}