import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoiceFilterChips extends StatelessWidget {
  const InvoiceFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      'all',
      'today',
      'this_week',
      'this_month',
      'paid',
      'unpaid',
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppPadding.md),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final label = filters[index];
          bool isSelected = label == 'all';

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(label.tr()),              selected: isSelected,
              onSelected: (val) {},
              selectedColor: context.colors.primary.withValues(alpha: 0.1),
              labelStyle: context.text.labelMedium?.copyWith(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: context.colors.outlineVariant),
              ),
            ),
          );
        },
      ),
    );
  }
}
