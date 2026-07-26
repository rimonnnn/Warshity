import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class CircelProgressIndecator extends StatelessWidget {
  final double? width;
  final double? height;
  const CircelProgressIndecator({super.key, this.height, this.width });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  width?? 40.w,
      height:height?? 40.h,
      child: CircularProgressIndicator(
        strokeWidth: 3.w,
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
      ),
    );
  }
}
