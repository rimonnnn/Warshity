import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';

class RememberPasswordWidget extends StatelessWidget {
  final String text;
  const RememberPasswordWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: context.colors.onSurfaceVariant, thickness: 1),
        ),
        WidthSpace(4),
        Text(text, style: context.text.bodyMedium),
        WidthSpace(4),
        Expanded(
          child: Divider(color: context.colors.onSurfaceVariant, thickness: 1),
        ),
      ],
    );
  }
}
