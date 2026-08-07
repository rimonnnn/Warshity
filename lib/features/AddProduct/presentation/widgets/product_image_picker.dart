import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({super.key, this.image, this.onTap, this.height});

  final Widget? image;
  final VoidCallback? onTap;
final double? height;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "product_image".tr(),
          style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8.h),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: double.infinity,
            height: height ?? 180.h,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.colors.outlineVariant,
                style: BorderStyle.solid,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                image ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42.sp,
                      color: context.colors.primary,
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      "upload_product_image".tr(),
                      style: context.text.titleSmall,
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "PNG, JPG",
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
