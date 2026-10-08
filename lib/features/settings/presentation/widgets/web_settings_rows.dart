import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

/// مربع الأيقونة المشترك بين الصفين
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.radius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // primaryContainer بدل primary بشفافية 10%، اللي كانت باهتة على الـ navy
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: scheme.primary, size: iconSize),
    );
  }
}

class SettingsInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SettingsInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        // حد خفيف يفصل الصف عن الكارت اللي حواليه
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, size: 52, iconSize: 25, radius: 14),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, size: 48, iconSize: 24, radius: 13),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
