import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.quantity,
    this.image,
    this.icon = Icons.inventory_2_outlined,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.imageBackgroundColor, this.height, this.width,
  });

  final String productName;
  final String productCode;
  final String price;
  final String quantity;

  /// لو فيه صورة اعرضها
  final Widget? image;

  /// لو مفيش صورة اعرض الأيقونة
  final IconData icon;

  final VoidCallback? onTap;

  final Color? backgroundColor;
  final Color? imageBackgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: width ?? 64.w,
              height: height ?? 64.w,
              decoration: BoxDecoration(
                color: imageBackgroundColor ?? context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: image != null
                  ? SizedBox.expand(
                      child: FittedBox(fit: BoxFit.cover, child: image!),
                    )
                  : Center(
                      child: Icon(
                        icon,
                        color: context.colors.primary,
                        size: 30.sp,
                      ),
                    ),
            ),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120.w,
                  child: Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  productCode,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: context.text.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  quantity,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
