import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ButtonBackWidget extends StatelessWidget {
  const ButtonBackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: 41.w,
        height: 41.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: () => GoRouter.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: context.colors.primary,
              textDirection: Directionality.of(context),
            ),
          ),
        ),
      ),
    );
  }
}