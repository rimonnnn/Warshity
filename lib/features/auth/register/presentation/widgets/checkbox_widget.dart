import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckboxWidget extends StatelessWidget {
  const CheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.text,
  });
  final bool value;
  final void Function(bool?)? onChanged;
  final double? width;
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        SizedBox(
          width: width ?? 300.w,
          child: Text(
            text ?? "confirm_checkbox".tr(),

            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
