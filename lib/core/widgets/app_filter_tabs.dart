import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppFilterTabs extends StatefulWidget {
  const AppFilterTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.icons,
    this.counts,
    this.height,
    this.spacing,
    this.padding,
    this.radius,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderColor,
    this.textStyle,
    this.autoScroll = true,
    this.alignment = AlignmentDirectional.centerStart,
  }) : assert(icons == null || icons.length == items.length),
       assert(counts == null || counts.length == items.length);

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Optional: icon لكل tab (نفس طول items)
  final List<IconData?>? icons;

  /// Optional: عدّاد/badge لكل tab (نفس طول items)
  final List<int?>? counts;

  final double? height;
  final double? spacing;
  final EdgeInsetsGeometry? padding;
  final double? radius;

  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  /// يعمل scroll للـ tab المختارة لو خارج الشاشة
  final bool autoScroll;

  /// مكان الـ tabs لما تكون أقل من عرض المساحة (مفيد على الويب)
  final AlignmentGeometry alignment;

  @override
  State<AppFilterTabs> createState() => _AppFilterTabsState();
}

class _AppFilterTabsState extends State<AppFilterTabs> {
  static const double _wideBreakpoint = 600;

  late List<GlobalKey> _keys;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    _scrollToSelected(animate: false);
  }

  @override
  void didUpdateWidget(covariant AppFilterTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _keys = List.generate(widget.items.length, (_) => GlobalKey());
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToSelected({bool animate = true}) {
    if (!widget.autoScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final i = widget.selectedIndex;
      if (i < 0 || i >= _keys.length) return;
      final ctx = _keys[i].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleTap(int index) {
    if (index != widget.selectedIndex && !kIsWeb) {
      HapticFeedback.selectionClick();
    }
    widget.onSelected(index);
  }

  /// الـ mouse wheel العمودي يحرّك القايمة أفقياً (لو فيه overflow بس)
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;

    final position = _controller.position;
    if (position.maxScrollExtent <= 0) return;

    final delta = event.scrollDelta;
    if (delta.dx.abs() > delta.dy.abs()) return; // أفقي أصلاً

    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final target = (position.pixels + delta.dy).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _controller.jumpTo(target);
    });
  }

  String _formatCount(int count) => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // على الشاشات العريضة (ويب/تابلت) نثبّت الأحجام بدل ما تكبر مع العرض
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final k = wide ? 1.0 : ScreenUtil().scaleWidth;

    final selectedBg = widget.selectedColor ?? cs.primary;
    final unselectedBg = widget.unselectedColor ?? cs.surfaceContainerLow;
    final selectedFg = widget.selectedTextColor ?? cs.onPrimary;
    final unselectedFg = widget.unselectedTextColor ?? cs.onSurfaceVariant;
    final border = widget.borderColor ?? cs.outlineVariant;
    final radius = widget.radius ?? 20 * k;

    // الارتفاع بيكبر مع text scale عشان النص ما يتقصش
    final height = MediaQuery.textScalerOf(
      context,
    ).scale(widget.height ?? 40 * k);

    final baseTextStyle =
        widget.textStyle ??
        theme.textTheme.labelLarge?.copyWith(fontSize: (wide ? 14 : 13) * k);

    final list = ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16 * k),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => SizedBox(width: widget.spacing ?? 8 * k),
      itemBuilder: (context, index) {
        final selected = widget.selectedIndex == index;
        final fg = selected ? selectedFg : unselectedFg;
        final icon = widget.icons?[index];
        final count = widget.counts?[index];

        return KeyedSubtree(
          key: _keys[index],
          child: ChoiceChip(
            showCheckmark: false,
            selected: selected,
            onSelected: (_) => _handleTap(index),
            selectedColor: selectedBg,
            backgroundColor: unselectedBg,
            elevation: 0,
            pressElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            side: BorderSide(color: selected ? selectedBg : border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.symmetric(horizontal: 14 * k),
            labelPadding: EdgeInsets.zero,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16 * k, color: fg),
                  SizedBox(width: 6 * k),
                ],
                Text(
                  widget.items[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: baseTextStyle?.copyWith(
                    color: fg,
                    // weight ثابت عشان ما يحصلش layout shift
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(width: 8 * k),
                  Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minWidth: 20 * k),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * k,
                      vertical: 2 * k,
                    ),
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: selected ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(10 * k),
                    ),
                    child: Text(
                      _formatCount(count),
                      style: TextStyle(
                        fontSize: 11 * k,
                        height: 1.2,
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          // السحب بالماوس/trackpad على الويب والديسكتوب
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: Align(
          alignment: widget.alignment,
          child: SizedBox(height: height, child: list),
        ),
      ),
    );
  }
}
