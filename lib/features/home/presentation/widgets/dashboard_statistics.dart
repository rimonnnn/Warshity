import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class DashBoardStatistics extends StatelessWidget {
  const DashBoardStatistics({
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
    final scheme = context.colors;
    final radius = BorderRadius.circular(borderRadius ?? AppRadius.md);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 220;

        return Material(
          color: color ?? scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: scheme.outlineVariant), // حد الكارت
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: scheme.primary.withValues(alpha: 0.08),
            highlightColor: scheme.primary.withValues(alpha: 0.04),
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(padding ?? (isMobile ? 12.sp : 16)),
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
                          style:
                              (isMobile
                                      ? context.text.bodySmall
                                      : context.text.bodyMedium)
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        icon ?? Icons.people,
                        size: iconSize ?? (isMobile ? 18.sp : 20),
                        color: scheme.primary, // الأيقونة teal زي الصورة
                      ),
                    ],
                  ),

                  HeightSpace(heightspace ?? 12.h),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                value ?? "0",
                                maxLines: 1,
                                style:
                                    (isMobile
                                            ? context.text.bodyLarge
                                            : context.text.bodyLarge)
                                        ?.copyWith(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                            ),
                          ),
                        ),
                        if (onTap != null)
                          Icon(
                            Icons.chevron_right_rounded,
                            size: isMobile ? 18.sp : 20,
                            color: scheme.onSurfaceVariant,
                            // السهم يتقلب تلقائيًا في RTL
                            textDirection: Directionality.of(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
