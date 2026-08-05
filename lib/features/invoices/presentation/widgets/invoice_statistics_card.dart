import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/constants/app_padding.dart';

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
    Color cardColor;
    switch (color) {
      case 'primary':
        cardColor = context.colors.primary;
        break;
      case 'secondary':
        cardColor = context.colors.secondary;
        break;
      case 'success':
        cardColor = context.appColors.success;
        break;
      case 'error':
        cardColor = context.colors.error;
        break;
      default:
        cardColor = context.colors.primary;
    }

    return Container(
      width: 140.w,
      padding: EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.tr(),
            style: context.text.labelLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
        ],
      ),
    );
  }
}