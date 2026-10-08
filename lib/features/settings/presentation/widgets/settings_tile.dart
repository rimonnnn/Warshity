import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showDivider = true,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return Column(
      children: [
        // onTap مباشرة على الـ ListTile بدل InkWell حواليه:
        // الـ ListTile بيرسم الـ ripple والـ hover بنفسه
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                // الأيقونة دي بتتقلب لوحدها في RTL
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
        ),

        if (showDivider)
          // indent = padding 16 + الأيقونة 36 + المسافة 16، فالخط يبدأ من تحت النص
          Divider(height: 1, indent: 68, color: scheme.outlineVariant),
      ],
    );
  }
}
