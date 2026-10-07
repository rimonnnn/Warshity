import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/constants/app_padding.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class InvoiceStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String color;

  const InvoiceStatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    final cardColor = switch (color) {
      'primary' => scheme.primary,
      'secondary' => scheme.secondary,
      'success' => context.appColors.success,
      'error' => scheme.error,
      _ => scheme.primary,
    };

    return Container(
      width: 140.w,
      padding: EdgeInsets.all(AppPadding.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
