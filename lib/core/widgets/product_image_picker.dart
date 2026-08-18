import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({
    super.key,
    required this.imageBytes,
    required this.onPick,
    this.height,
    this.enabled = true,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final double? height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPick : null,
      child: Container(
        width: double.infinity,
        height: height ?? 150.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colors.outline,
          ),
          borderRadius: BorderRadius.circular(
            AppRadius.md,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48.sp,
                    color: context.colors.primary,
                  ),
                  HeightSpace(8.h),
                  Text(
                    'Upload Product Image'.tr(),
                  ),
                  HeightSpace(4.h),
                  Text(
                    'PNG, JPG',
                  ),
                ],
              ),
      ),
    );
  }
}