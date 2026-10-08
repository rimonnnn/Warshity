import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TopBarButton extends StatelessWidget {
  const TopBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final radius = BorderRadius.circular(10);
    final foreground = filled ? scheme.onPrimary : scheme.primary;

    return Material(
      // الزر الثانوي: شفاف بحد، بدل surfaceContainerHighest بشفافية 10% اللي مكانتش بتبان
      color: filled ? scheme.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        hoverColor: foreground.withValues(alpha: 0.08),
        splashColor: foreground.withValues(alpha: 0.12),
        child: ConstrainedBox(
          // 42 زي حقل البحث وشيب التاريخ في الـ top bar
          constraints: const BoxConstraints(minHeight: 42),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
