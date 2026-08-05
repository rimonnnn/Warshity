import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class VersionCard extends StatelessWidget {
  const VersionCard({
    super.key,
    required this.image,
    required this.version,
    this.title,
    this.backgroundColor,
    this.borderRadius,
    this.imageWidth,
    this.imageHeight,
  });

  final String image;
  final String version;

  final String? title;
  final Color? backgroundColor;
  final double? borderRadius;

  final double? imageWidth;
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppRadius.lg,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            image,
            width: imageWidth ?? 90.w,
            height: imageHeight ?? 90.h,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 16.h),

          Text(
            title ?? "Warshity",
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            version,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}