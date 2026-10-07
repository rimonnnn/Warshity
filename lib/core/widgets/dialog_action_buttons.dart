import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

class DialogActionButtons extends StatelessWidget {
  const DialogActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false,
    this.cancelbuttonheight,
    this.savebuttonheight,
    this.fontSize,
    this.fontSize1,
  });

  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool isLoading;
  final double? cancelbuttonheight;
  final double? savebuttonheight;
  final double? fontSize;
  final double? fontSize1;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Row(
      children: [
        Expanded(
          child: PrimaryButtonWidget(
            width: double.infinity,
            height: cancelbuttonheight ?? 56.h,
            buttonText: 'Cancel'.tr(),
            buttonColor: scheme.error, // كانت Colors.red
            textColor: scheme.onError, // كانت Colors.white
            fontSize: fontSize,
            iconData: Icons.cancel_outlined,
            iconeColor: scheme.onError,
            iconSize: 20,
            buttonspacing: 3,
            onPress: onCancel,
          ),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: PrimaryButtonWidget(
            width: double.infinity,
            height: savebuttonheight ?? 56.h,
            buttonText: 'save'.tr(),
            buttonColor: scheme.primary,
            textColor: scheme.onPrimary, // كانت Colors.white
            iconData: Icons.save,

            fontSize: fontSize1,
            iconeColor: scheme.onPrimary,
            iconSize: 20,
            buttonspacing: 3,
            isLoading: isLoading,
            onPress: onSave,
          ),
        ),
      ],
    );
  }
}
