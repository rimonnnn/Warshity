import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SettingsCategory {
  final String titleKey;
  final IconData icon;

  const SettingsCategory({required this.titleKey, required this.icon});
}

class SidebarCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const SidebarCategory({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final radius = BorderRadius.circular(14);

    // Material بدل AnimatedContainer: الخلفية على Container كانت بتغطي الـ ripple.
    // Material بيعمل animation للون لوحده (animationDuration)، والـ ripple بيبان
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        animationDuration: const Duration(milliseconds: 180),
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: scheme.primary.withValues(alpha: 0.08),
          splashColor: scheme.primary.withValues(alpha: 0.12),
          child: ConstrainedBox(
            // 48 على الأقل: مساحة ضغط مريحة بالماوس واللمس
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
