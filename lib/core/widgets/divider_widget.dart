import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class Dividerwidget extends StatelessWidget {
  const Dividerwidget({
    super.key, this.child,
  });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.colors.onSurfaceVariant,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: child
        ),
        Expanded(
          child: Divider(
            color: context.colors.onSurfaceVariant,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}