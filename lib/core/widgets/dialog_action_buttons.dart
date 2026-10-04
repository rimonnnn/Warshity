import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Row(
      children: [
        Expanded(
          child: PrimaryButtonWidget(
            width: double.infinity,
            height: cancelbuttonheight ?? 56.h,
            buttonText: 'Cancel'.tr(),
            buttonColor: Colors.red,
            textColor: Colors.white,
            fontSize: fontSize,
            iconData: Icons.cancel_outlined,
            iconeColor: Colors.white,
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
            textColor: Colors.white,
            iconData: Icons.save,

            fontSize: fontSize1,
            iconeColor: Colors.white,
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
