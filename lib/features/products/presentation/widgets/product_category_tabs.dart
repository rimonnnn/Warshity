import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductCategoryTabs extends StatelessWidget {
  const ProductCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => onSelected(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: context.text.bodyMedium?.copyWith(
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
