import 'package:easy_localization/easy_localization.dart';
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
    this.icon = Icons.inventory_2_outlined,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.imageBackgroundColor,
    this.height,
    this.width,
    required this.image,
  });

  final String productName;
  final String productCode;
  final double price;
  final int quantity;

  final Widget? image;
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
              child: SizedBox.expand(
                child: FittedBox(fit: BoxFit.cover, child: image),
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
                Row(
                  children: [
                    Text(
                      '${price % 1 == 0 ? price.toInt() : price}',

                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "EGP".tr(),
                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                Text(
                  quantity.toString(),
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
