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
    final scheme = context.colors;

    // SafeArea من تحت بس: يمنع الزر من الالتصاق بشريط الـ gestures
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.md,
          vertical: AppPadding.sm,
        ),
        child: PrimaryButtonWidget(
          // onPrimary: النص والأيقونة غامقين فوق الـ teal الفاتح في الـ dark
          iconeColor: scheme.onPrimary,
          textColor: scheme.onPrimary,
          iconData: Icons.receipt_long_outlined,
          onPress: onPressed,
          buttonText: 'create_invoice'.tr(),
          height: 56,
          fontSize: fontSize,
          buttonColor: scheme.primary,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
