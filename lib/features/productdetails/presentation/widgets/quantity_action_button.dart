import 'package:flutter/material.dart';

import 'package:warshity/core/extensions/context_extension.dart';

class QuantityActionButton extends StatelessWidget {
  const QuantityActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: primary ? colors.primary.withValues(alpha: .10) : colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primary
                  ? colors.primary.withValues(alpha: .18)
                  : colors.outlineVariant,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? colors.outline
                : primary
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
