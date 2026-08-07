import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductUnitSelector extends StatelessWidget {
  const ProductUnitSelector({
    super.key,
    required this.selectedUnit,
    required this.onSelected,
  });

  final String selectedUnit;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final units = [
      "piece".tr(),
      "meter".tr(),
      "kg".tr(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "unit1".tr(),
          style: context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8.h),

        Wrap(
          spacing: 12.w,
          children: units.map((unit) {
            final isSelected = unit == selectedUnit;

            return ChoiceChip(
              label: Text(unit),
              selected: isSelected,
              onSelected: (_) => onSelected(unit),
            );
          }).toList(),
        ),
      ],
    );
  }
}