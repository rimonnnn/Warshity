import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showDivider = true, this.trailing,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDivider;
final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: trailing ?? const Icon(Icons.arrow_forward_ios),
          ),
        ),

        if (showDivider)
          Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}
