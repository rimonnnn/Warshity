import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CustomerMapCard extends StatelessWidget {
  const CustomerMapCard({
    super.key,
    required this.image,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  final Widget image;
  final double? height;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppRadius.md,
      ),
      child: Container(
        width: double.infinity,
        height: height ?? 180.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.md,
          ),
        ),
        child: image,
      ),
    );
  }
}