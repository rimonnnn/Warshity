import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/quantity_bottom_sheet.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.image,
    this.icon = Icons.inventory_2_outlined,
    this.onTap,
    this.onIncrease,
    this.onDecrease,
    this.onQuantityChanged,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.imageBackgroundColor,
    this.height,
    this.width,
  });

  final String productName;
  final String productCode;
  final double price;
  final int quantity;

  final Widget? image;
  final IconData icon;

  final VoidCallback? onTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final Future<void> Function(int quantity)? onQuantityChanged;


  final Color? backgroundColor;
  final Color? imageBackgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: imageBackgroundColor ?? context.colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                clipBehavior: Clip.antiAlias,
                child: image != null
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: image,
                        ),
                      )
                    : Center(
                        child: Icon(
                          icon,
                          size: 26.sp,
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      productCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${price % 1 == 0 ? price.toInt() : price}',
                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${'EGP'.tr()}',
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Material(
                    color: context.colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: BorderSide(color: context.colors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: quantity > 0 ? onDecrease : null,
                          activeColor: context.colors.onSurfaceVariant,
                        ),

                        InkWell(
                          onTap: () {
                            QuantityBottomSheet.show(
                              context: context,
                              quantity: quantity,
                              onQuantityChanged: (newQuantity) async {
                                await onQuantityChanged?.call(newQuantity);
                              },
                            );
                          },
                          child: Container(
                            constraints: BoxConstraints(minWidth: 28.w),
                            height: 32.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              quantity.toString(),
                              style: context.text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: onIncrease,
                          activeColor: context.colors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.activeColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(
          icon,
          size: 18.sp,
          color: onTap != null ? activeColor : context.colors.outline,
        ),
      ),
    );
  }
}
