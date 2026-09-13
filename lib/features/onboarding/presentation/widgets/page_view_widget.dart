import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class PageViewWidget extends StatelessWidget {
  final double width;
  final String title;
  final String describtion;

  const PageViewWidget({
    super.key,
    required this.width,
    required this.title,
    required this.describtion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 260.h,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: context.colors.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 24.r,
              spreadRadius: 0,
              offset: Offset(0, 8.h),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            HeightSpace(43),
            Text(
              describtion,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
