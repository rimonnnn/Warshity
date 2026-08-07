import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class BestSellingProducts extends StatelessWidget {
  const BestSellingProducts({super.key});

  static const products = ['wood', 'glue', 'accessories', 'rivets', ];

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(products[index].tr()),
          backgroundColor: context.colors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ),
      ),
    ),
  );
}
