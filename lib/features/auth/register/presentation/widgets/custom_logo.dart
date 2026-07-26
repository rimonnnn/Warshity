import 'package:flutter/material.dart';
import 'package:warshity/core/styling/app_colors.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius, required this.logoPath,
  });
  final double width;
  final double height;
  final double borderRadius;
  final String logoPath;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppColors.primary,
      ),
      child: Image.asset(logoPath),
    );
  }
}
