import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class TopBarIconButton extends StatelessWidget {
  const TopBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;

  /// اختياري: لو اتبعت بيظهر على الـ hover، ويتقرا بالـ screen readers
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final radius = BorderRadius.circular(10);

    final button = Material(
      // كان surfaceContainerHighest بشفافية 10%، مش بيبان على الـ navy
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        hoverColor: scheme.primary.withValues(alpha: 0.08),
        splashColor: scheme.primary.withValues(alpha: 0.12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
      ),
    );

    if (tooltip == null) return button;

    return Tooltip(message: tooltip!, child: button);
  }
}
