import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.trailing,
  });

  final String title;
  final List<Widget> children;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  /// عنصر اختياري في نهاية الـ header (مثلًا زر تعديل)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    // Material بدل Container بـ decoration: لو الخلفية على Container،
    // الـ ripple بتاع الـ tiles اللي جواه بيتغطى بلونه ومبيبانش
    return Material(
      color: backgroundColor ?? scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        // حد بدل الظل: الظل الأسود 5% مكانش بيبان على الـ navy
        side: BorderSide(color: scheme.outlineVariant),
      ),
      // يقص الـ ripple على حواف القسم المستديرة
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding:
                padding ??
                EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}
