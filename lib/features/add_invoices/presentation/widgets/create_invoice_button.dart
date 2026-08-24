import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

class CreateInvoiceButton extends StatelessWidget {
  final double? fontSize;
  final void Function()? onPressed;
  final bool isLoading;

  const CreateInvoiceButton({
    super.key,
    this.fontSize,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm,
      ),
      child: PrimaryButtonWidget(
        iconeColor: context.colors.surface,
        iconData: Icons.receipt_long_outlined,
        onPress: onPressed,
        buttonText: 'create_invoice'.tr(),
        height: 56,
        fontSize: fontSize,
        buttonColor: context.colors.primary,
        isLoading: isLoading,
      ),
    );
  }
}