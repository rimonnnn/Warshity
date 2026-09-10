import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  Widget box({
    double? width,
    double? height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceContainerHighest,
      highlightColor: context.colors.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top container
            box(
              width: double.infinity,
              height: 100.h,
            ),

            SizedBox(height: 32.h),

            // Statistics
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                mainAxisExtent: 160.h,
              ),
              itemBuilder: (_, index) {
                return box(
                  width: double.infinity,
                  height: 160.h,
                );
              },
            ),

            SizedBox(height: 32.h),

            // Low stock
            box(
              width: double.infinity,
              height: 180.h,
            ),

            SizedBox(height: 32.h),

            // Section title
            box(
              width: 150.w,
              height: 25.h,
              radius: 8,
            ),

            SizedBox(height: 16.h),

            // Recent operations
            box(
              width: double.infinity,
              height: 250.h,
            ),
          ],
        ),
      ),
    );
  }
}