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
    final cs = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit'.tr(),
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        HeightSpace(8.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: units.map((unit) {
            final selected = selectedUnit == unit;
            final fg = selected ? cs.onPrimary : cs.onSurfaceVariant;

            return ChoiceChip(
              showCheckmark: false,
              label: Text(unit),
              selected: selected,
              onSelected: enabled ? (_) => onChanged(unit) : null,
              selectedColor: cs.primary,
              backgroundColor: cs.surfaceContainerLow,
              disabledColor: cs.surfaceContainerLow,
              elevation: 0,
              pressElevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              side: BorderSide(
                color: selected ? cs.primary : cs.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              labelStyle: context.text.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}