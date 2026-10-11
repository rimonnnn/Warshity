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

  /// أقل من العرض ده نعتبره موبايل
  static const double _compactBreakpoint = 480;

  String _dayLabel(DateTime day, String locale, {required bool compact}) {
    final pattern = compact ? 'EEE' : 'EEEE';
    try {
      return DateFormat(pattern, locale).format(day);
    } catch (_) {
      return DateFormat('EEE').format(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxValue = values.fold<double>(0, math.max);
    final today = DateTime.now();
    final locale = context.locale.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _compactBreakpoint;

        final height = chartHeight ?? (isCompact ? 140.0 : 180.0);
        final barGap = isCompact ? 8.0 : 16.0;

        final titles = Column(
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
              maxLines: isCompact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );

        final legendChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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

              Flexible(
                child: Text(
                  legend ?? 'workshop_sales'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding ?? (isCompact ? 16 : 24)),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer, // موحّد مع باقي الكروت
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // على الموبايل الـ legend تحت العنوان، على الويب جنبه
              if (isCompact) ...[
                titles,

                const HeightSpace(12),

                legendChip,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titles),

                    const SizedBox(width: 16),

                    legendChip,
                  ],
                ),

              HeightSpace(isCompact ? 20 : 28),

              SizedBox(
                height: height + _SalesBar.extraHeight,
                child: Stack(
                  children: [
                    // خطوط الشبكة الخفيفة ورا الأعمدة
                    Positioned.fill(
                      top: _SalesBar.valueLabelHeight,
                      bottom: _SalesBar.dayLabelHeight,
                      child: const _ChartGrid(),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < values.length; i++) ...[
                          if (i != 0) SizedBox(width: barGap),
                          Expanded(
                            child: _SalesBar(
                              value: values[i],
                              maxValue: maxValue,
                              maxHeight: height,
                              isToday: i == values.length - 1,
                              isCompact: isCompact,
                              label: _dayLabel(
                                today.subtract(
                                  Duration(days: values.length - 1 - i),
                                ),
                                locale,
                                compact: isCompact,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// خطوط أفقية خفيفة (فوق - نص - القاعدة)
class _ChartGrid extends StatelessWidget {
  const _ChartGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final lineColor = scheme.outlineVariant.withValues(alpha: 0.5);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 3; i++) Container(height: 1, color: lineColor),
      ],
    );
  }
}

class _SalesBar extends StatefulWidget {
  const _SalesBar({
    required this.value,
    required this.maxValue,
    required this.maxHeight,
    required this.isToday,
    required this.isCompact,
    required this.label,
  });

  final double value;
  final double maxValue;
  final double maxHeight;
  final bool isToday;
  final bool isCompact;
  final String label;

  static const double valueLabelHeight = 20;
  static const double dayLabelHeight = 24;
  static const double extraHeight = valueLabelHeight + dayLabelHeight;

  @override
  State<_SalesBar> createState() => _SalesBarState();
}

class _SalesBarState extends State<_SalesBar> {
  // hover للويب فقط، state محلية ومش بتأثر على باقي التطبيق
  bool _isHovered = false;

  String _formatValue(String locale) {
    try {
      return NumberFormat.compact(locale: locale).format(widget.value);
    } catch (_) {
      return NumberFormat.compact().format(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final locale = context.locale.toString();

    final barHeight = widget.maxValue <= 0
        ? 4.0
        : math.max(4.0, widget.value / widget.maxValue * widget.maxHeight);

    // على الموبايل نعرض القيمة لليوم والـ hover بس عشان الزحمة
    final showValue = !widget.isCompact || widget.isToday || _isHovered;

    final barColor = widget.isToday
        ? scheme.primary
        : scheme.primary.withValues(alpha: _isHovered ? 0.65 : 0.35);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: '${widget.label}\n${widget.value.toStringAsFixed(2)}',
        triggerMode: TooltipTriggerMode.tap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: _SalesBar.valueLabelHeight,
              child: showValue
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatValue(locale),
                        maxLines: 1,
                        style: context.text.labelSmall?.copyWith(
                          color: widget.isToday
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: barHeight,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 56),
              decoration: BoxDecoration(
                // اليوم: primary كامل، باقي الأيام: نفس اللون بشفافية
                color: barColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: _SalesBar.dayLabelHeight - 8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  maxLines: 1,
                  style: context.text.bodySmall?.copyWith(
                    color: widget.isToday
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: widget.isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
