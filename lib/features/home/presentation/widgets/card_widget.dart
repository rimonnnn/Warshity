import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.onTap,
    this.title,
    this.icon,
    this.padding,
    this.heightspace,
    this.iconSize,
    this.value,
  });

  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final String? title;
  final IconData? icon;
  final double? padding;
  final double? heightspace;
  final double? iconSize;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 220;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color ?? context.colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
            ),
            padding: EdgeInsets.all(padding ?? (isMobile ? 12.sp : 16.sp)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title ?? "total_clients".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isMobile
                            ? context.text.bodySmall
                            : context.text.bodyMedium,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Icon(
                      icon ?? Icons.people,
                      size: iconSize ?? (isMobile ? 18.sp : 20.sp),
                      color: context.colors.onSurfaceVariant,
                    ),
                  ],
                ),

                HeightSpace(heightspace ?? 12.h),

                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value ?? "0",
                        maxLines: 2,
                        style:
                            (isMobile
                                    ? context.text.headlineSmall
                                    : context.text.headlineMedium)
                                ?.copyWith(
                                  color: context.colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
