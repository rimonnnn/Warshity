import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class UnitSelector extends StatelessWidget {
  const UnitSelector({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
    this.enabled = true,
  });

  final List<String> units;
  final String selectedUnit;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Unit'.tr(),
          style: context.text.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        HeightSpace(8.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: units.map(
            (unit) {
              return ChoiceChip(
                label: Text(unit),
                selected:
                    selectedUnit == unit,
                onSelected: enabled
                    ? (_) => onChanged(unit)
                    : null,
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}