import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class BestSellingProducts extends StatelessWidget {
  const BestSellingProducts({super.key});

  static const products = ['wood', 'glue', 'accessories', 'rivets'];

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => Padding(
          // EdgeInsetsDirectional بدل EdgeInsets.only(right):
          // المسافة بين الشيبس كانت على اليمين دايمًا، فكانت بتتعكس في العربي
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Chip(
            label: Text(
              products[index].tr(),
              style: context.text.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            // surfaceContainer بحد، بدل surfaceContainerLow اللي كان بيدوب في الخلفية
            backgroundColor: scheme.surfaceContainer,
            side: BorderSide(color: scheme.outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
          ),
        ),
      ),
    );
  }
}
