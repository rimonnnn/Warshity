import 'package:easy_localization/easy_localization.dart';
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
    final width = imageWidth ?? 90.w;
    final height = imageHeight ?? 90.h;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        // حد بدل الظل: الظل الأسود 5% مكانش بيبان على الـ navy
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              image,
              width: width,
              height: height,
              fit: BoxFit.contain,
              // لو الصورة ماتحملتش، يظهر placeholder بدل ما الكارت يبوظ
              errorBuilder: (_, __, ___) => SizedBox(
                width: width,
                height: height,
                child: Icon(
                  Icons.storefront_outlined,
                  size: 40,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            title ?? "masiter".tr(),
            textAlign: TextAlign.center,
            style: context.text.titleLarge?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          // الإصدار في pill صغير بدل نص عادي
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              // min: من غيرها الـ Row بياخد العرض كله والـ pill بيتمط
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  version,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "1.0.0",
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
