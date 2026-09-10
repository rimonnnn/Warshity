import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class CustomerDetailsShimmer extends StatelessWidget {
  const CustomerDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.surfaceContainerHighest,
      highlightColor: context.colors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),

            HeightSpace(16.h),

            _buildDebtCard(context),

            HeightSpace(20.h),

            _buildSectionTitle(),

            HeightSpace(12.h),

            _buildInvoiceList(context),

            HeightSpace(20.h),

            _buildStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _box(width: 56.w, height: 56.w, radius: 28.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 140.w, height: 16.h),
                SizedBox(height: 10.h),
                _box(width: 100.w, height: 12.h),
                SizedBox(height: 8.h),
                _box(width: 180.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _box(width: 48.w, height: 48.w, radius: 12.r),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(width: 90.w, height: 12.h),
                SizedBox(height: 10.h),
                _box(width: 130.w, height: 18.h),
              ],
            ),
          ),
          _box(width: 70.w, height: 36.h, radius: 8.r),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: _box(width: 150.w, height: 20.h),
        ),
        _box(width: 70.w, height: 36.h, radius: 8.r),
      ],
    );
  }

  Widget _buildInvoiceList(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            width: double.infinity,
            height: 72.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _box(width: 42.w, height: 42.w, radius: 10.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _box(width: 130.w, height: 13.h),
                      SizedBox(height: 8.h),
                      _box(width: 80.w, height: 10.h),
                    ],
                  ),
                ),
                _box(width: 65.w, height: 14.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard(context)),
        SizedBox(width: 12.w),
        Expanded(child: _statCard(context)),
      ],
    );
  }

  Widget _statCard(BuildContext context) {
    return Container(
      height: 90.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _box(width: 42.w, height: 42.w, radius: 10.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _box(width: 55.w, height: 11.h),
                SizedBox(height: 8.h),
                _box(width: 70.w, height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required double width, required double height, double? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 6.r),
      ),
    );
  }
}
