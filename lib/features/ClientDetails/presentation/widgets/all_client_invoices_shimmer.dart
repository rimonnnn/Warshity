import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class AllClientInvoicesShimmer extends StatelessWidget {
  const AllClientInvoicesShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceContainerHighest,
      highlightColor: context.colors.surface,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, __) {
          return Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }
}
