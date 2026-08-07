import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerBalanceType extends StatelessWidget {
  const CustomerBalanceType({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "balance_type".tr(),
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: value,
                onChanged: (v) => onChanged(v!),
                title: Text("credit".tr()),
                contentPadding: EdgeInsets.zero,
              ),
            ),

            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: value,
                onChanged: (v) => onChanged(v!),
                title: Text("debit".tr()),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}