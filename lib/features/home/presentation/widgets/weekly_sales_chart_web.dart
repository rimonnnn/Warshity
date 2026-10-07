import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class WeeklySalesChartWeb extends StatelessWidget {
  const WeeklySalesChartWeb({
    super.key,
    required this.values,
    this.title,
    this.subtitle,
    this.legend,
    this.chartHeight,
    this.borderRadius,
    this.padding,
  });

  /// المبيعات اليومية مرتبة من الأقدم للأحدث (آخر عنصر = النهارده)
  final List<double> values;
  final String? title;
  final String? subtitle;
  final String? legend;
  final double? chartHeight;
  final double? borderRadius;
  final double? padding;

  String _dayLabel(DateTime day, String locale) {
    try {
      return DateFormat('EEEE', locale).format(day);
    } catch (_) {
      return DateFormat('EEE').format(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final height = chartHeight ?? 160;
    final maxValue = values.fold<double>(0, math.max);
    final today = DateTime.now();
    final locale = context.locale.toString();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding ?? 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer, // موحّد مع باقي الكروت
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'weekly_sales_flow'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle ?? 'weekly_sales_subtitle'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    legend ?? 'workshop_sales'.tr(),
                    style: context.text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const HeightSpace(24),

          SizedBox(
            height: height + 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  if (i != 0) const SizedBox(width: 16),
                  Expanded(
                    child: _SalesBar(
                      value: values[i],
                      maxValue: maxValue,
                      maxHeight: height,
                      isToday: i == values.length - 1,
                      label: _dayLabel(
                        today.subtract(Duration(days: values.length - 1 - i)),
                        locale,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesBar extends StatelessWidget {
  const _SalesBar({
    required this.value,
    required this.maxValue,
    required this.maxHeight,
    required this.isToday,
    required this.label,
  });

  final double value;
  final double maxValue;
  final double maxHeight;
  final bool isToday;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final barHeight = maxValue <= 0
        ? 4.0
        : math.max(4.0, value / maxValue * maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: value.toStringAsFixed(2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: barHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              // اليوم: primary كامل، باقي الأيام: نفس اللون بشفافية
              color: isToday
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(
            color: isToday ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
