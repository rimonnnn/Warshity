import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/styling/app_assets.dart';

class LogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  const LogoWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        width: width ?? 200.w,
        height: height ?? 200.w,
        AppAssets.logo,
        fit: BoxFit.cover,
      ),
    );
  }
}
