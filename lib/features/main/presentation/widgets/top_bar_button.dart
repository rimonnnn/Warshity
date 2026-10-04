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
    return Material(
      color: filled
          ? context.colors.primary
          : context.colors.surfaceContainerHighest.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled
                    ? context.colors.onPrimary
                    : context.colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? context.colors.onPrimary
                      : context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
