// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class TopImageWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final String imageUrl;
  const TopImageWidget({
    super.key,
    this.width,
    this.height,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 240.w,
      height: height ?? 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: context.colors.surfaceContainer,
      ),
      child: Image.asset(imageUrl, fit: BoxFit.contain),
    );
  }
}
